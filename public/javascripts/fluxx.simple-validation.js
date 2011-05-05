(function($){
  $.fn.extend({
    initValidator: function() {
      $('#new_loi').validate({
        rules: {
        "loi[email]": {required: true, email: true},
        "loi[applicant]": {required: true, minlength: 6},
        "loi[organization]": {required: true, minlength: 6}
        }
      });
    }
	});
})(jQuery);

$(document).ready(function() {
	$.fn.initValidator();
});
