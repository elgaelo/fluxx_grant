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
      insta.template_map = {:matching_users => "matching_users_list", :matching_organizations => "matching_organizations_list"}
    end
    base.insta_edit Loi do |insta|
      insta.icon_style = ICON_STYLE
      insta.template = 'loi_form'
      insta.template_map = {:connect_organization =>  "connect_organization", :connect_user => "connect_user"}
    end
    base.insta_post Loi do |insta|
      insta.template = 'loi_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put Loi do |insta|
      insta.template = 'loi_form'
      insta.template_map = {:connect_organization =>  "connect_organization", :connect_user => "connect_user"}
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.pre do |triple|
        if params[:user]
          params.delete(:loi)
          params[:connect_user] = true
          @user = User.new(params[:user])
          @user.save
          #Todo Somehow we need to kick a validation error and show the errors on the form
        end
        if params[:organization]
          params.delete(:loi)
          params[:connect_organization] = true
          @organization = Organizatio.new(params[:organization])
          @organization.save
          #Todo Somehow we need to kick a validation error and show the errors on the form
        end
      end
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        if params[:link_user] || params[:link_organization]
          if (params[:link_user].to_i > 0)
            @user = User.find(params[:link_user].to_i)
          end
          if (params[:link_organization].to_i > 0)
            @organization = Organization.find(params[:link_organization].to_i)
          end
          model.link_user @user if @user
          model.link_organization @organization if @organization
        end
        if params[:disconnect_user]
          model.update_attribute "user_id", nil
        end
        if params[:disconnect_organization]
          model.update_attribute "organization_id", nil
        end
      end
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