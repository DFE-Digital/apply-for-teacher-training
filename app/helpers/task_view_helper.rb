module TaskViewHelper
  def task_view_header(choice)
    case choice&.task_view_group
    when 1 then 'Confirm deferred offers'
    when 2 then 'Deadline approaching: make decision about application'
    when 3 then 'Give feedback: you did not make a decision in time'
    when 4 then 'Received – make a decision'
    when 5 then 'Interviewing'
    when 6 then 'Offers pending conditions (previous cycle)'
    when 7 then 'Waiting for candidate to respond to offer'
    when 8 then 'Offers pending conditions (current cycle)'
    when 9 then 'Successful candidates'
    when 10 then 'Deferred offers'
    else
      'No action needed'
    end
  end
end
