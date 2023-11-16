module TaskViewHelper
  def task_view_header(choice)
    case choice&.task_view_group
    when 1 then 'Received over 30 days ago - make a decision now'
    when 2 then 'Confirm deferred offers'
    when 3 then 'Deadline approaching: make decision about application'
    when 4 then 'Give feedback: you did not make a decision in time'
    when 5 then 'Received – make a decision'
    when 6 then 'Interviewing'
    when 7 then 'Offers pending conditions (previous cycle)'
    when 8 then 'Waiting for candidate to respond to offer'
    when 9 then 'Offers pending conditions (current cycle)'
    when 10 then 'Successful candidates'
    when 11 then 'Deferred offers'
    else
      'No action needed'
    end
  end

  def relative_date_text_color(choice)
    case choice&.task_view_group
    when 1 then 'app-status-indicator--red'
    else
      ''
    end
  end
end
