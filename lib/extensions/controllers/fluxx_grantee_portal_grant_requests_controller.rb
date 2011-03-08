module FluxxGranteePortalGrantRequestsController
  ICON_STYLE = 'style-grant-requests'
  def self.included(base)
    base.send :include, FluxxCommonRequestsController
    base.insta_index Request do |insta|
      insta.format do |format|
        format.html do |triple|
          redirect_to grantee_portal_index_path
        end
      end
    end
    base.insta_show GrantRequest do |insta|
      insta.template = 'grant_request_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.layout = 'grantee_portal'
      insta.skip_card_footer = true
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_show_format_html controller_dsl, outcome, default_block if user_can_access_request
        end
      end
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        set_enabled_variables controller_dsl
        redirect_to grantee_portal_index_path unless @model.granted
      end
    end
    base.add_grant_request_install_role GrantRequest
    base.insta_new GrantRequest do |insta|
      insta.layout = 'grantee_portal'
      insta.skip_card_footer = true
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.layout = 'grantee_portal'
      insta.skip_card_footer = true
      insta.icon_style = ICON_STYLE
      # TODO lamda stuff
      insta.format do |format|
        format.html do |triple|
          if @model.grantee_portal_state != 'draft'
            redirect_to grantee_portal_grant_request_path
          else
            controller_dsl, outcome, default_block = triple
            grant_request_edit_format_html controller_dsl, outcome, default_block if user_can_access_request
          end
        end
      end
      
    end
    base.insta_post GrantRequest do |insta|
      insta.template = 'grant_request_form'
      insta.layout = 'grantee_portal'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put GrantRequest do |insta|
      insta.use_redirect_not_201 = true
      insta.layout = 'grantee_portal'
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.format do |format|
        format.html do |triple|
          controller_dsl, outcome, default_block = triple
          grant_request_update_format_html controller_dsl, outcome, default_block  if user_can_access_request
        end
      end
    end
    base.insta_delete GrantRequest do |insta|
      insta.layout = 'grantee_portal'
      insta.template = 'grant_request_form'
      insta.icon_style = ICON_STYLE
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def user_can_access_request
      can_access = (@model.program_organization_id == current_user.primary_user_organization_id || @model.fiscal_organization_id == current_user.primary_user_organization_id)
      if  !can_access
        logger.debug("Grantee portal user #{current_user.login} tried to access request #{@model.grant_or_request_id} and was not authorized")
        render :text => "foo", :status => 404
      end
      can_access
    end
  end
end