module TaskViewHelper
  def task_view_header(choice)
    case choice&.task_view_group
    when 1 then 'deferredOffersPendingReconfirmation'
    when 2 then 'previousCyclePendingConditions'
    when 3 then 'Give feedback: you did not respond in time'
    when 4 then 'Deadline approaching: respond to candidate'
    when 5 then 'Ready for review'
    when 6 then 'waitingOn'
    when 7 then 'pendingConditions'
    when 8 then 'conditionsMet'
    when 9 then 'deferredOffers'
    else
      'Other'
    end
  end
end
