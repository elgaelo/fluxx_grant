# Supplements FluxxOrganizationsController in fluxx_crm
module FluxxGrantOrganizationsController
  def self.included(base)
    base.insta_index Organization do |insta|
      insta.filter_title = "Organizations Filter"
      insta.filter_template = 'organizations/organization_filter'
      insta.search_conditions = (lambda do |params, controller_dsl|
        if params[:related_org_ids]
          {}
        else
          {:parent_org_id => 0}
        end
      end)
    end
    
    base.insta_related Organization do |insta|
      insta.add_related do |related|
        related.display_name = 'Requests'
        related.for_search do |model|
          model.related_requests
        end
        related.display_template = '/grant_requests/related_request'
      end
      insta.add_related do |related|
        related.display_name = 'Grants'
        related.for_search do |model|
          model.related_grants
        end
        related.display_template = '/grant_requests/related_request'
      end
      insta.add_related do |related|
        related.display_name = 'People'
        related.for_search do |model|
          model.related_users
        end
      end
      insta.add_related do |related|
        related.display_name = 'Trans'
        related.for_search do |model|
          model.related_transactions
        end
        related.display_template = '/request_transactions/related_request_transactions'
      end
      insta.add_related do |related|
        related.display_name = 'Reports'
        related.for_search do |model|
          model.related_reports
        end
        related.display_template = '/request_reports/related_documents'
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