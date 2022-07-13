class EndOfCycleEmailsComponent < ViewComponent::Base
  EndOfCycleEmail = Struct.new(:name, :date, :candidates_size, keyword_init: true)

  def end_of_cycle_emails
    [
      {
        name: 'Apply 1 deadline reminder',
        date: "#{CycleTimetable.apply_1_deadline_first_reminder.strftime('%d %b %Y')} and #{CycleTimetable.apply_1_deadline_second_reminder.strftime('%d %b %Y')}",
        candidates_size: apply_1_candidates,
      },
      {
        name: 'Apply 2 deadline reminder',
        date: "#{CycleTimetable.apply_2_deadline_first_reminder.strftime('%d %b %Y')} and #{CycleTimetable.apply_2_deadline_second_reminder.strftime('%d %b %Y')}",
        candidates_size: apply_2_candidates,
      },
      {
        name: 'Find has opened',
        date: CycleTimetable.find_reopens.strftime('%d %b %Y'),
        candidates_size: candidates_to_notify_about_find_and_apply,
      },
      {
        name: 'Apply has opened',
        date: CycleTimetable.apply_reopens.strftime('%d %b %Y'),
        candidates_size: candidates_to_notify_about_find_and_apply,
      },
      {
        name: 'Find is now open (providers)',
        date: CycleTimetable.find_reopens.strftime('%d %b %Y'),
        candidates_size: providers_to_notify_about_find_and_apply,
      },
      {
        name: 'Apply is now open (providers)',
        date: CycleTimetable.apply_reopens.strftime('%d %b %Y'),
        candidates_size: providers_to_notify_about_find_and_apply,
      },
    ].map do |cycle_data|
      EndOfCycleEmail.new(cycle_data)
    end
  end

  def apply_1_candidates
    GetApplicationsToSendDeadlineRemindersTo.deadline_reminder_candidates_apply_1.count
  end

  def apply_2_candidates
    GetApplicationsToSendDeadlineRemindersTo.deadline_reminder_candidates_apply_2.count
  end

  def candidates_to_notify_about_find_and_apply
    GetUnsuccessfulAndUnsubmittedCandidates.call.count
  end

  def providers_to_notify_about_find_and_apply
    GetProvidersToNotifyAboutFindAndApply.call.count
  end
end
