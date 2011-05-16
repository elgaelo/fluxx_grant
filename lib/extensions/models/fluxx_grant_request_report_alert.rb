module FluxxGrantRequestReportAlert
  extend FluxxModuleHelper

  when_included do
    attr_matcher :report_type, :state
    attr_matcher :name => :lead_user_ids, :attribute => 'request.lead_user_ids', :comparer => 'in'
    attr_matcher :name => :program_id, :attribute => 'request.program_id'
    attr_matcher :name => :due_in, :attribute => :due_at, :comparer => "due_in"
    attr_matcher :name => :overdue_by, :attribute => :due_at, :comparer => "overdue_by"
  end
end
