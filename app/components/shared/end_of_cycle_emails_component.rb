class EndOfCycleEmailsComponent < ViewComponent::Base
  EndOfCycleEmail = Struct.new(:link, :date, :candidates_size, keyword_init: true)

  def end_of_cycle_emails
    [
      {
        link: preview_email_link('Apply 1 deadline reminder', path: 'candidate_mailer/eoc_deadline_reminder'),

        date: "#{email_date(:apply_1_deadline_first_reminder)} and #{email_date(:apply_1_deadline_second_reminder)}",
        candidates_size: apply_1_candidates,
      },
      {
        link: preview_email_link('Apply 2 deadline reminder', path: 'candidate_mailer/eoc_deadline_reminder'),
        date: "#{email_date(:apply_2_deadline_first_reminder)} and #{email_date(:apply_2_deadline_second_reminder)}",
        candidates_size: apply_2_candidates,
      },
      {
        link: preview_email_link('Find has opened', path: 'candidate_mailer/find_has_opened'),
        date: email_date(:find_reopens),
        candidates_size: candidates_to_notify_about_find_and_apply,
      },
      {
        link: preview_email_link('Apply has opened', path: 'candidate_mailer/new_cycle_has_started_with_unsuccessful_application'),
        date: email_date(:apply_reopens),
        candidates_size: candidates_to_notify_about_find_and_apply,
      },
      {
        link: preview_email_link('Find is now open (providers)', path: 'provider_mailer/find_service_is_now_open'),
        date: email_date(:find_reopens),
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

  def email_date(event)
    CycleTimetable.send(event).strftime('%e %B %Y')
  end

  def preview_email_link(title, path:)
    if Rails.application.config.action_mailer.show_previews
      govuk_link_to(
        title,
        url_for(controller: 'rails/mailers', action: 'preview', path: path),
      )
    else
      title
    end
  end
end
