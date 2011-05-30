class ReviewerFeedbackReport < ActionController::ReportBase
  set_type_as_show

  def initialize report_id
    super report_id
    self.filter_template = 'modal_reports/reviewer_feedback_filter'
  end

  def report_label
    'Reviewer Feedback Report'
  end

  def report_description
    'External Reviewer Feedback By Grant Report (Excel Table)'
  end

  def compute_show_document_headers controller, show_object, params
    ['fluxx_' + 'reviewer_feedback' + '_' + Time.now.strftime("%m%d%y") + ".xls", 'application/vnd.ms-excel']
  end

  def compute_show_document_data controller, show_object, params
    active_record_params = params[:active_record_base] || {}

    start_date = if active_record_params[:start_date].blank?
      nil
    else
      Time.parse(active_record_params[:start_date]) rescue nil
    end || Time.now
    end_date = if active_record_params[:end_date].blank?
      nil
    else
      Time.parse(active_record_params[:end_date]) rescue nil
    end || Time.now

    programs = params[:active_record_base][:program_id]
    programs = if params[:active_record_base][:program_id]
      Program.where(:id => params[:active_record_base][:program_id]).all rescue nil
    end || []
    programs = programs.compact

    lead_users = params[:active_record_base][:lead_user_ids]
    lead_users = if params[:active_record_base][:lead_user_ids]
      User.where(:id => params[:active_record_base][:lead_user_ids]).all rescue nil
    end || []
    lead_users = lead_users.compact
    p "ESH: have arguments start_date = #{start_date.inspect}, end_date = #{end_date.inspect}, program_ids=#{programs.map(&:id).inspect}"


    reviews = 
      RequestReview.find_by_sql [%{select 
                  request_id,
                  request_reviews.created_by_id request_reviews_created_by_id,
                  request_reviews.rating
                  from request_reviews, requests req
                  where request_reviews.request_id = req.id and
                  #{start_date ? " grant_agreement_at >= '#{start_date.sql}' AND " : ''} 
                  #{end_date ? " grant_agreement_at <= '#{end_date.sql}' AND " : ''}
                  req.deleted_at IS NULL AND 
                  granted = 0 AND
                  req.state not in (?) AND
                  (1=? or req.program_id in (?)) AND
                  (1=? or req.program_lead_id in (?))
                  }, 
                  Request.all_rejected_states,
                  programs.empty?, programs,
                  lead_users.empty?, lead_users
      ]
    user_ids = reviews.map(&:request_reviews_created_by_id).uniq
    request_ids = reviews.map(&:request_id).uniq
    users = User.where(:id => user_ids).order('last_name, first_name').all
    users_by_userid = users.inject({}) {|acc, user| acc[user.id] = user; acc}
    requests = Request.find_by_sql ["
    select id, if(type = 'GrantRequest', (select name from organizations where id = program_organization_id), fip_title) grant_name,
    base_request_id,
    amount_requested,
    amount_recommended,
    duration_in_months,
    grant_begins_at begin_date,
    if(grant_begins_at is not null and duration_in_months is not null, date_add(date_add(req.grant_begins_at, INTERVAL duration_in_months month), interval -1 DAY), grant_begins_at) end_date
    from requests req 
    where id in (?)", request_ids]
    requests_by_requestid = requests.inject({}) {|acc, request| acc[request.id] = request; acc}

    reviews_by_request_id = {}
    reviews_by_request_id = reviews.inject({}) do |acc, review|
      review_hash = acc[review.request_id] || {}
      acc[review.request_id] = review_hash
      review_hash[review.request_reviews_created_by_id] = review
      acc
    end

    output = StringIO.new

    workbook = WriteExcel.new(output)
    worksheet = workbook.add_worksheet

    # Set up some basic formats:
    non_wrap_bold_format = workbook.add_format()
    non_wrap_bold_format.set_bold()
    non_wrap_bold_format.set_valign('top')
    bold_format = workbook.add_format()
    bold_format.set_bold()
    bold_format.set_align('center')
    bold_format.set_valign('top')
    bold_format.set_text_wrap()
    header_format = workbook.add_format()
    header_format.set_bold()
    header_format.set_bottom(1)
    header_format.set_align('top')
    header_format.set_text_wrap()
    solid_black_format = workbook.add_format()
    solid_black_format.set_bg_color('black')
    amount_format = workbook.add_format()
    amount_format.set_num_format("#{I18n.t 'number.currency.format.unit'}#,##0")
    amount_format.set_valign('bottom')
    amount_format.set_text_wrap()
    number_format = workbook.add_format()
    number_format.set_num_format(0x01)
    number_format.set_valign('bottom')
    number_format.set_text_wrap()
    date_format = workbook.add_format()
    date_format.set_num_format(15)
    date_format.set_valign('bottom')
    date_format.set_text_wrap()
    text_format = workbook.add_format()
    text_format.set_valign('top')
    text_format.set_text_wrap()
    header_format = workbook.add_format(
      :bold => 1,
      :color => 9,
      :bg_color => 8)
    workbook.set_custom_color(40, 214, 214, 214)
    sub_total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 40)
    sub_total_border_format = workbook.add_format(
       :top => 1,
       :bold => 1,
       :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
       :color => 8,      
       :bg_color => 40)      
    total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 22)
    total_border_format = workbook.add_format(
      :top => 1,
      :bold => 1,
      :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
      :color => 8,
      :bg_color => 22)
    workbook.set_custom_color(41, 128, 128, 128)      
    final_total_format = workbook.add_format(
      :bold => 1,
      :color => 8,
      :bg_color => 41)
    final_total_border_format = workbook.add_format(
      :top => 1,
      :bold => 1,
      :num_format => "#{I18n.t 'number.currency.format.unit'}#,##0",
      :color => 8,
      :bg_color => 41)
    
    # Add page summary
    # worksheet.write(0, 0, 'The Energy Foundation', non_wrap_bold_format)
    worksheet.write(1, 0, 'Reviewer Feedback', non_wrap_bold_format)
    worksheet.write(2, 0, 'Start Date: ' + start_date.mdy)
    worksheet.write(3, 0, 'End Date: ' + end_date.mdy)
    worksheet.write(4, 0, "Report Date: " + Time.now.mdy)
    
    # Adjust column widths
    worksheet.set_column(0, 9, 10)
    worksheet.set_column(1, 1, 15)
    worksheet.set_column(7, 7, 20)
    worksheet.set_column(9, 9, 15)
    
    ["Grant Name", "Grant ID", "Amount Requested", "Amount Recommended", "Start Date", "End Date", "Duration"].
      each_with_index{|label, index| worksheet.write(6, index, label, header_format)}
    
    p "ESH: have users=#{users.map{|u| u.full_name}.join(', ')}"
    users.each_with_index do |user, index|
      worksheet.write(6, index + 7, user.first_name + ' ' + user.last_name, header_format)
    end
    worksheet.write(6, users.size + 7, 'Average', header_format)
    
    row_start = 6
    row = row_start
    # Calculate letter combinations for column names for the sake of formulas; A, B, C, .. Z, AB, AC, ... ZZ
    column_letters = ('A'..'Z').to_a
    column_letters = column_letters + column_letters.map {|letter1| column_letters.map {|letter2| letter1 + letter2 } }
    column_letters = column_letters.flatten
    
    request_ids.each do |request_id|
      column=0
      request = requests_by_requestid[request_id]
      
      worksheet.write(row += 1, column, request.grant_name)
      worksheet.write(row, column += 1, request.base_request_id)
      worksheet.write(row, column += 1, (request.amount_requested.to_i rescue 0), amount_format)
      worksheet.write(row, column += 1, (request.amount_recommended.to_i rescue 0), amount_format)
      worksheet.write(row, column += 1, (request.begin_date ? (Time.parse(request.begin_date).mdy rescue '') : ''), date_format)
      worksheet.write(row, column += 1, (request.end_date ? (Time.parse(request.end_date).mdy rescue '') : ''), date_format)
      worksheet.write(row, column += 1, request.duration_in_months, number_format)
      
      start_user_column = column + 1
      users.each do |user|
        review = reviews_by_request_id[request_id]
        user_review = review[user.id.to_s] if review
        worksheet.write(row, column += 1, (user_review ? (user_review.rating.to_i rescue '') : ''), number_format)
      end
      end_user_column = column
      
      avg_formula = "#{column_letters[start_user_column]}#{row+1}:#{column_letters[end_user_column]}#{row+1}"
      p "ESH: have a formula of: #{avg_formula}"
      worksheet.write(row, column+=1, ("=AVERAGE(#{avg_formula})"), number_format)
    end

    workbook.close
    output.string
  end
end