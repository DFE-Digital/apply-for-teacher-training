module TaskViewHelper
  def task_view_header(choice)
    case choice&.task_view_group
    when 1 then 'Deferred offers: review and confirm'
    when 2 then 'Offers pending conditions (previous cycle)'
    when 3 then 'Give feedback: you did not respond in time'
    when 4 then 'Deadline approaching: respond to candidate'
    when 5 then 'Ready for review'
    when 6 then 'Waiting for candidate action'
    when 7 then 'Offers pending conditions (current cycle)'
    when 8 then 'Successful candidates'
    when 9 then 'Deferred offers'
    else
      'No action needed'
    end
  end
end
