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
    ApplicationForm
    .joins(:candidate)
    .where(submitted_at: nil, phase: 'apply_1', recruitment_cycle_year: RecruitmentCycle.current_year)
    .where.not(candidate: { unsubscribed_from_emails: true }).count
  end

  def apply_2_candidates
    ApplicationForm
    .joins(:candidate)
    .where(submitted_at: nil, phase: 'apply_2', recruitment_cycle_year: RecruitmentCycle.current_year)
    .where.not(candidate: { unsubscribed_from_emails: true }).count
  end

  def candidates_to_notify_about_find_and_apply
    GetUnsuccessfulAndUnsubmittedCandidates.call.count
  end

  def providers_to_notify_about_find_and_apply
    Provider
      .joins('INNER JOIN provider_users_providers ON providers.id = provider_users_providers.provider_id')
      .joins('INNER JOIN provider_users ON provider_users.id = provider_users_providers.provider_user_id')
      .where.not(Arel.sql(providers_whose_users_have_been_chased))
      .order('providers.name')
      .distinct
      .count
  end

  def providers_whose_users_have_been_chased
    <<-SQL.squish
      EXISTS(
        SELECT 1
        FROM chasers_sent
        WHERE chased_type = 'Provider'
        AND chased_id = providers.id
        AND chaser_type = 'find_service_open_organisation_notification'
      )
    SQL
  end
end
