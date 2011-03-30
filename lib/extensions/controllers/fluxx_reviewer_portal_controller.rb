module FluxxReviewerPortalController
  def self.included(base)
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    ITEMS_PER_PAGE = 10
    def index
      if current_user.is_reviewer?

        client_store = ClientStore.where(:user_id => fluxx_current_user.id, :client_store_type => 'reviewer portal').first ||
                       ClientStore.create(:user_id => fluxx_current_user.id, :client_store_type => 'reviewer portal', :data => {:pages => {:requests => 1, :grants => 1, :reports => 1, :transactions => 1}}.to_json, :name => "Default")

        settings = client_store.data.de_json
        table = 'requests'
        all = !params[:requests] && !params[:grants] && ! params[:reports] && !params[:transactions]
        page = params[:page] ? params[:page] : settings["pages"][table]
        settings["pages"][table] = page if (table != :all)

        requests = Request.where("requests.type = ? AND requests.deleted_at IS NULL", "GrantRequest")
        request_ids = requests.map { |request| request.id }

        # TODO AML: We need to filter the request list based on the reviewers role and the request state
        @requests = requests.where(:granted => false).order("created_at desc").paginate :page => settings["pages"]["requests"], :per_page => ITEMS_PER_PAGE
        @title = "Requests"
        template = "_grant_request_list"

        if params[:page]
          client_store.data = settings.to_json
          client_store.save
          @data = @requests
          render template, :layout => false
        end

      else
       redirect_back_or_default dashboard_index_path
      end
    end

  end
end