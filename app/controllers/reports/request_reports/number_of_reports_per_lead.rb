class NumberOfReportsPerLead < ActionController::ReportBase

  set_type_as_index
  def report_label
    "Reports Pending Lead Approval"
  end
  def compute_index_plot_data controller, index_object, params, models
    hash = {:library => "jqplot"}
    hash[:title] = report_label
    hash[:data] = []
    query = "select count(rr.id) as count, u.first_name, u.last_name, rr.report_type as report_type, u.id as user_id from request_reports rr
      left join requests r on r.id = rr.request_id
      right join users u on u.id = r.program_lead_id
      where rr.state != 'approved' and (report_type = 'Eval' or report_type = 'FinalBudget' or report_type = 'FinalNarrative')
      group by u.id, rr.report_type
      order by rr.report_type,  u.last_name"
    data = RequestReport.connection.execute(RequestReport.send(:sanitize_sql, [query, models.map(&:id)]))
    last_type = nil
    xaxis = []
    data.each_hash do |row|
      if (row["report_type"] != last_type)
        last_type = row["report_type"]
        hash[:data] << []

      end
      xaxis << "#{row['first_name']} #{row['last_name']}"
      hash[:data].last << row["count"]
    end

    hash[:axes] = { :xaxis => {:ticks => xaxis.inject({}) {|h,v| h[v]=h[v].to_i+1; h}.reject{|k,v| v==1}.keys, :tickOptions => { :angle => -30 }}, :yaxis => { :min => 0 }}
    hash[:series] = [ {:label => "Eval"}, {:label => "FinalBudget"}, {:label => "FinalNarrative"} ]
    hash[:stackSeries] = false;
    hash[:type] = "bar"

    hash.to_json

  end

  def report_filter_text controller, index_object, params, models

  end

  def report_summary controller, index_object, params, models

  end

  def report_legend controller, index_object, params, models
    legend = [{:table => ['Report Type', 'Number of Reports Due']}]
    query = "select count(rr.id) as count, report_type from request_reports rr where (report_type = 'Eval' or report_type = 'FinalBudget' or report_type = 'FinalNarrative') and id in (?) group by report_type order by report_type"
    filter = []
    params["request_report"].each do |key, value|
      next if key == "report_type"
      if value.is_a? Array
        value.each {|val| filter << "request_report[#{key}][]=#{val}"}
      else
        filter << "request_report[#{key}]=#{value}"
      end
    end if params["request_report"]
    RequestReport.connection.execute(Request.send(:sanitize_sql, [query, models.map(&:id)])).each_hash do |result|
      legend << { :table => [result["report_type"], result["count"]],
                  :filter =>  filter.join("&") + "&request_report[report_type][]=#{result['report_type']}",
        "listing_url".to_sym => controller.request_reports_path, "card_title".to_sym => "#{result['report_type']} Reports"}
    end
    legend
  end

end
