module FluxxGrantRequestReportAlert
  extend FluxxModuleHelper

  when_included do
    attr_matcher :report_type, :state
    attr_matcher :name => :lead_user_ids, :attribute => 'request.lead_user_ids', :comparer => 'in'
    attr_matcher :name => :program_id, :attribute => 'request.program_id',
                 :from_params => lambda{|request_report_params| request_report_params[:request_hierarchy].map{|rh| rh.split("-").first}}

    attr_matcher :name => :due_within_days, :attribute => :due_at, :comparer => "due_in"
    attr_matcher :name => :overdue_by_days, :attribute => :due_at, :comparer => "overdue_by"

    attr_recipient_role :program_lead,
                        :recipient_finder => lambda{|request_report| request_report.request.program_lead }

    attr_recipient_role :grantee_org_owner,
                        :recipient_finder => lambda{|request_report| request_report.request.grantee_org_owner },
                        :friendly_name => "Primary contact"

    attr_recipient_role :grantee_signatory,
                        :recipient_finder => lambda{|request_report| request_report.request.grantee_signatory },
                        :friendly_name => "Primary signatory"

    attr_recipient_role :fiscal_org_owner,
                        :recipient_finder => lambda{|request_report| request_report.request.fiscal_org_owner },
                        :friendly_name => "Fiscal organization owner"

    attr_recipient_role :fiscal_signatory,
                        :recipient_finder => lambda{|request_report| request_report.request.program_lead }
  end
end
