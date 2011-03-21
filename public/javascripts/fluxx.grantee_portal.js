(function($){
  $.fn.extend({
    initGranteePortal: function() {
      $.fn.installFluxxDecorators();
      $('.notice').delay(2000).fadeOut('slow');
    },
		installFluxxDecorators: function() {
		  $.each($.fluxx.decorators, function(key,val) {
		    $(key).live.apply($(key), val);
		  });
		},
		loadTable: function($table, pageIncrement) {
      $table.css('opacity', '0.2');
			$table.attr('data-src', $table.attr('data-src').replace(/page=(\d+)/, function(a,b){
			  var page = parseInt(b) + pageIncrement;
			  return 'page=' + page;
			}));
			$.ajax({
        url: $table.attr('data-src'),
		    success: function(data, status, xhr){
				  $table.html(data);
          $table.css('opacity', '1');
        }
      });
		}
	});
	
	$.extend(true, {
		fluxx: {
		  decorators: {
	      'a.prev-page': [
	        'click', function(e) {          
                e.preventDefault();
                var $elem = $(this);
                if ($elem.hasClass('disabled'))
                    return;
                var $area = $elem.parents('.container');
                    $.fn.loadTable($area, -1);
	        }
	      ],
	      'a.next-page': [
	        'click', function(e) {          
                e.preventDefault();
                var $elem = $(this);
                if ($elem.hasClass('disabled'))
                    return;
                var $area = $elem.parents('.container');
                $.fn.loadTable($area, 1);
	        }
	      ],
          'a.to-upload': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              $.modal('<div class="upload-queue"></div>', {
                minWidth: 700,
                minHeight: 400,
                closeHTML: '<span>Close</span>',
                close: true,
                closeOverlay: true,
                escClose:true,
                opacity: 50,
                onShow: function () {
                  $('.upload-queue').pluploadQueue({
                    url: $elem.attr('href'),
                    runtimes: 'html5',
                    multipart: false,
                    filters: [{title: "Allowed file types", extensions: $elem.attr('data-extensions')}]
                  });
                },
                onClose: function(){

                  var $area = $elem.parents('.reports');
                  if (!$area.attr('data-src'))
                    $area = $elem.parents('.partial');
                  $.fn.loadTable($area, 0);
                  $.modal.close();
                }
              });
            }
          ],
          'a.submit-workflow': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              var $area = $elem.parents('.reports');
              if ($area.length == 0)
                $area = $elem.parents('.container');
              if ($elem.attr('data-confirm') && !confirm($elem.attr('data-confirm')))
                return false;
              $.ajax({
                url: $elem.attr('href'),
                type: 'PUT',
                data: {},
		            success: function(data, status, xhr){
				          $.fn.loadTable($area, 0);
                }
              });
            }
          ],
          'a.delete-report': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              var $area = $elem.parents('.reports');
              if ($area.length == 0)
                $area = $elem.parents('.container');
              if (confirm('The report you recently submitted will be deleted. Are you sure?'))
              $.ajax({
                url: $elem.attr('href'),
                type: 'DELETE',
                data: {},
		            success: function(data, status, xhr){
				          $.fn.loadTable($area, 0);
                }
              });
            }
          ],
          'a.as-delete': [
            'click', function(e) {
              e.preventDefault();
              var $elem = $(this);
              var $area = $elem.parents('.container');
              if (confirm('This request will be deleted. Are you sure?'))
                $.ajax({
                  url: $elem.attr('href'),
                  type: 'DELETE',
		          success: function(data, status, xhr){
				    $.fn.loadTable($area, 0);
                  }
                });
            }
          ],
          'input.open-link' : [
             'click', function(e) {
               e.preventDefault();
               var $elem = $(this);
               window.location = $elem.attr('data-href');
            }
          ]
		 }
	    }
	});
})(jQuery);

$(document).ready(function() {
	$.fn.initGranteePortal();
});
