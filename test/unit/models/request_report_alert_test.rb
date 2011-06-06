require 'test_helper'

class RequestReportAlertTest < ActiveSupport::TestCase
  def alert_is_triggered_for_request_report(request_report_opts)
    request_report = RequestReport.make(request_report_opts)
    rtu = RealtimeUpdate.make(:type_name => RequestReport.name, :model_id => request_report.id)

    alert_is_triggered
  end

  def alert_is_triggered
    is_triggered = false
    Alert.with_triggered_alerts!{|triggered_alert, matching_rtus| is_triggered = true }
    is_triggered
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

  test "alert is not triggered if the equality matcher does not match the state" do
    create_alert(:state => "new", :overdue_by => "8")
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

  test "rtus are not used to match overdue_by matchers" do
    create_alert(:overdue_by => "8")
    RequestReport.make(:due_at => 10.days.ago)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end

  test "rtus are not used to match due_at matchers" do
    create_alert(:due_in => "8")
    RequestReport.make(:due_at => 7.days.from_now)
    RealtimeUpdate.delete_all

    assert alert_is_triggered
  end
end
