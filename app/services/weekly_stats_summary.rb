class WeeklyStatsSummary
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def as_slack_message
    <<~MARKDOWN
      *:flashlight: Shine a light on stats, your weekly update from Apply*

      *So far this cycle we have seen:*

      :key: #{pluralize(number_with_delimiter(candidate_signups(current_cycle_period)), 'total candidate signup')} | This point last cycle we had #{number_with_delimiter(candidate_signups(previous_cycle_period))}

      *Domestic applications :gb:*

      :postbox: #{pluralize(number_with_delimiter(applications_submitted(current_cycle_period, current_year, domestic)), 'total application')} submitted | This point last cycle we had #{number_with_delimiter(applications_submitted(previous_cycle_period, previous_year, domestic))}
      :yes_vote: #{pluralize(number_with_delimiter(offers_made(current_cycle_period, current_year, domestic)), 'total offer')} made | This point last cycle we had #{number_with_delimiter(offers_made(previous_cycle_period, previous_year, domestic))}
      :handshake: #{pluralize(number_with_delimiter(offers_accepted(current_cycle_period, current_year, domestic)), 'total offer')} accepted | This point last cycle we had #{number_with_delimiter(offers_accepted(previous_cycle_period, previous_year, domestic))}
      :no_vote: #{pluralize(number_with_delimiter(rejections_issued(current_cycle_period, current_year, domestic)), 'total rejection')} issued | This point last cycle we had #{number_with_delimiter(rejections_issued(previous_cycle_period, previous_year, domestic))}
      :sleeping: #{pluralize(number_with_delimiter(inactive_applications(current_cycle_period, current_year, domestic)), 'application')} turned to inactive
      #{teacher} #{pluralize(number_with_delimiter(candidates_recruited(current_cycle_period, current_year, domestic)), 'total candidate')} recruited | This point last cycle we had #{number_with_delimiter(candidates_recruited(previous_cycle_period, previous_year, domestic))}

      *International applications :earth_#{%w[africa americas asia].sample}:*

      :postbox: #{pluralize(number_with_delimiter(applications_submitted(current_cycle_period, current_year, international)), 'total application')} submitted | This point last cycle we had #{number_with_delimiter(applications_submitted(previous_cycle_period, previous_year, international))}
      :yes_vote: #{pluralize(number_with_delimiter(offers_made(current_cycle_period, current_year, international)), 'total offer')} made | This point last cycle we had #{number_with_delimiter(offers_made(previous_cycle_period, previous_year, international))}
      :handshake: #{pluralize(number_with_delimiter(offers_accepted(current_cycle_period, current_year, international)), 'total offer')} accepted | This point last cycle we had #{number_with_delimiter(offers_accepted(previous_cycle_period, previous_year, international))}
      :no_vote: #{pluralize(number_with_delimiter(rejections_issued(current_cycle_period, current_year, international)), 'total rejection')} issued | This point last cycle we had #{number_with_delimiter(rejections_issued(previous_cycle_period, previous_year, international))}
      :sleeping: #{pluralize(number_with_delimiter(inactive_applications(current_cycle_period, current_year, international)), 'application')} turned to inactive
      #{teacher} #{pluralize(number_with_delimiter(candidates_recruited(current_cycle_period, current_year, international)), 'total candidate')} recruited | This point last cycle we had #{number_with_delimiter(candidates_recruited(previous_cycle_period, previous_year, international))}


      _Please note these numbers are as of 11am and are not to be used for reporting purposes_

      :wave: Have a good weekend all
    MARKDOWN
  end

  def candidate_signups(period)
    Candidate.where(created_at: period).count
  end

  def applications_submitted(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { sent_to_provider_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

  def offers_made(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { offered_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

  def offers_accepted(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { accepted_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

  def candidates_recruited(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { recruited_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

  def rejections_issued(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { rejected_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

  def inactive_applications(period, recruitment_cycle, applications_scope)
    applications_scope.where(application_choices: { inactive_at: period, current_recruitment_cycle_year: recruitment_cycle }).count
  end

private

  def international
    ApplicationForm.international.joins(:application_choices)
  end

  def domestic
    ApplicationForm.domestic.joins(:application_choices)
  end

  def previous_cycle_period
    cycle_started = CycleTimetable.apply_opens(previous_year)
    cycle_started..CycleTimetable.this_day_last_cycle
  end

  def current_cycle_period
    cycle_started = CycleTimetable.apply_opens
    cycle_started..Time.zone.now
  end

  def previous_year
    CycleTimetable.previous_year
  end

  def current_year
    CycleTimetable.current_year
  end

  def technologist
    rand(2) == 1 ? ':male-technologist:' : ':female-technologist:'
  end

  def teacher
    rand(2) == 1 ? ':male-teacher:' : ':female-teacher:'
  end
end
