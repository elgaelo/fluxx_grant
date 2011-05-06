module FluxxLoisController
  ICON_STYLE = 'style-lois'

  def self.included(base)
    base.insta_index Loi do |insta|
      insta.template = 'loi_list'
      insta.filter_title = "Lois Filter"
      insta.filter_template = 'lois/loi_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show Loi do |insta|
      insta.template = 'loi_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        instance_variable_set '@edit_enabled', false
      end
    end
    base.insta_edit Loi do |insta|
      insta.template = 'loi_form'
      insta.icon_style = ICON_STYLE
        insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          if params[:connect_organization]
            insta.template = "connect_organization"
          end
          default_block.call
        end
      end
    end
    base.insta_post Loi do |insta|
      insta.template = 'loi_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Loi do |insta|
      insta.template = 'loi_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete Loi do |insta|
      insta.template = 'loi_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related Loi do |insta|
      insta.add_related do |related|
      end
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end
end