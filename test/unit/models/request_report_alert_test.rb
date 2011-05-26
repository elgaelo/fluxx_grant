require 'test_helper'

class RequestReportAlertTest < ActiveSupport::TestCase
  def alert_is_triggered_for_request_report(request_report_opts)
    request_report = RequestReport.make(request_report_opts)
    rtu = RealtimeUpdate.make(:type_name => RequestReport, :model_id => request_report.id)

    alert_is_triggered = false
    Alert.with_triggered_alerts!{|triggered_alert, matching_rtus| alert_is_triggered = true }
    alert_is_triggered
  end

  def create_alert(alert_opts)
    RequestReportAlert.create!(:name => alert_opts.delete(:name) || "an alert").tap do |alert|
      alert.update_attributes(alert_opts)
    end
  end

  def setup
    RealtimeUpdate.delete_all
  end

  test "alert is triggered if the overdue matcher matches the rtu" do
    create_alert(:state => "approved", :overdue_by => "8")
    assert alert_is_triggered_for_request_report(:state => "approved", :due_at => 10.days.ago)
  end

  test "alert is not triggered if the overdue matcher does not match the rtu" do
    create_alert(:state => "approved", :overdue_by => "11")
    assert !alert_is_triggered_for_request_report(:state => "approved", :due_at => 10.days.ago)
  end

  test "alert is triggered if the due_in matcher matches the rtu" do
    create_alert(:state => "approved", :due_in => "8")
    assert alert_is_triggered_for_request_report(:state => "approved", :due_at => 7.days.from_now)
  end

  test "alert is not triggered if the due_in matcher does not match the rtu" do
    create_alert(:state => "approved", :due_in => "11")
    assert !alert_is_triggered_for_request_report(:state => "approved", :due_at => 12.days.from_now)
  end
end
