class StatsSummary
  include ActionView::Helpers::TextHelper

  def as_slack_message
    <<~MARKDOWN
      *Today on Apply*
      _Please note these numbers are as of 5pm and are not to be used for reporting purposes_

      :wave: #{pluralize(candidate_signups(today), 'candidate signup')} | #{candidate_signups(this_day_last_year)} last cycle

      *Domestic applications :gb: :flag-ie:*

      :#{mailbox_emoji(applications_submitted(today, domestic))}: #{pluralize(applications_submitted(today, domestic), 'application')} submitted | #{applications_submitted(this_day_last_year, domestic)} last cycle
      :#{%w[man woman].sample}-tipping-hand: #{pluralize(offers_made(today, domestic), 'offer')} made | #{offers_made(this_day_last_year, domestic)} last cycle
      :#{%w[man woman].sample}-tipping-hand: #{pluralize(offers_accepted(today, domestic), 'offer')} accepted | #{offers_accepted(this_day_last_year, domestic)} last cycle
      :#{%w[man woman].sample}-gesturing-no: #{pluralize(rejections_issued(today, domestic), 'rejection')} issued | #{rejections_issued(this_day_last_year, domestic)} last cycle
      :sleeping: #{pluralize(inactive_applications(today, domestic), 'application')} turned to inactive
      :handshake: #{pluralize(candidates_recruited(today, domestic), 'candidate')} recruited | #{candidates_recruited(this_day_last_year, domestic)} last cycle

      *International applications :earth_#{%w[africa americas asia].sample}:*

      :#{mailbox_emoji(applications_submitted(today, international))}: #{pluralize(applications_submitted(today, international), 'application')} submitted | #{applications_submitted(this_day_last_year, international)} last cycle
      :#{%w[man woman].sample}-tipping-hand: #{pluralize(offers_made(today, international), 'offer')} made | #{offers_made(this_day_last_year, international)} last cycle
      :#{%w[man woman].sample}-tipping-hand: #{pluralize(offers_accepted(today, international), 'offer')} accepted | #{offers_accepted(this_day_last_year, international)} last cycle
      :#{%w[man woman].sample}-gesturing-no: #{pluralize(rejections_issued(today, international), 'rejection')} issued | #{rejections_issued(this_day_last_year, international)} last cycle
      :sleeping: #{pluralize(inactive_applications(today, international), 'application')} turned to inactive
      :handshake: #{pluralize(candidates_recruited(today, international), 'candidate')} recruited | #{candidates_recruited(this_day_last_year, international)} last cycle

    MARKDOWN
  end

  def candidate_signups(period)
    Candidate.where(created_at: period).count
  end

  def applications_submitted(period, applications_scope)
    applications_scope.where(application_choices: { sent_to_provider_at: period }).count
  end

  def offers_made(period, applications_scope)
    applications_scope.where(application_choices: { offered_at: period }).count
  end

  def offers_accepted(period, applications_scope)
    applications_scope.where(application_choices: { accepted_at: period }).count
  end

  def candidates_recruited(period, applications_scope)
    applications_scope.where(application_choices: { recruited_at: period }).count
  end

  def rejections_issued(period, applications_scope)
    applications_scope.where(application_choices: { rejected_at: period }).count
  end

  def inactive_applications(period, applications_scope)
    applications_scope.where(application_choices: { inactive_at: period }).count
  end

private

  def international
    ApplicationForm.international.joins(:application_choices)
  end

  def domestic
    ApplicationForm.domestic.joins(:application_choices)
  end

  def today
    Time.zone.now.beginning_of_day..Time.zone.now
  end

  def this_day_last_year
    @this_day_last_year ||= this_day_last_cycle.beginning_of_day..this_day_last_cycle
  end

  def this_day_last_cycle
    @this_day_last_cycle ||= RecruitmentCycleTimetable.this_day_last_cycle
  end

  def mailbox_emoji(message_count)
    message_count.zero? ? 'mailbox_with_no_mail' : 'mailbox_with_mail'
  end
end
