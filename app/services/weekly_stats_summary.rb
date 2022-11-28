class WeeklyStatsSummary
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper

  def as_slack_message
    <<~MARKDOWN
      *:flashlight: Shine a light on stats, your weekly update from Apply*

      *So far this cycle we have seen:*

      :key: #{pluralize(number_with_delimiter(candidate_signups(current_cycle_period)), 'total candidate signup')} | This point last cycle we had #{number_with_delimiter(candidate_signups(previous_cycle_period))}
      #{technologist} #{pluralize(number_with_delimiter(applications_begun(current_cycle_period, current_year, 'apply_1')), 'total initial application')} begun | This point last cycle we had #{number_with_delimiter(applications_begun(previous_cycle_period, previous_year, 'apply_1'))}
      #{technologist} #{pluralize(number_with_delimiter(applications_begun(current_cycle_period, current_year, 'apply_2')), 'total Apply again application')} begun | This point last cycle we had #{number_with_delimiter(applications_begun(previous_cycle_period, previous_year, 'apply_2'))}
      :postbox: #{pluralize(number_with_delimiter(applications_submitted(current_cycle_period, current_year)), 'total application')} submitted | This point last cycle we had #{number_with_delimiter(applications_submitted(previous_cycle_period, previous_year))}
      :yes_vote: #{pluralize(number_with_delimiter(offers_made(current_cycle_period, current_year)), 'total offer')} made | This point last cycle we had #{number_with_delimiter(offers_made(previous_cycle_period, previous_year))}
      :no_vote: #{pluralize(number_with_delimiter(rejections_issued(current_cycle_period, current_year)), 'total rejection')} issued#{rejections_issued(current_cycle_period, current_year).positive? ? ", of which #{pluralize(number_with_delimiter(rbd_count(current_cycle_period, current_year)), 'was')} RBD" : nil} | This point last cycle we had #{number_with_delimiter(rejections_issued(previous_cycle_period, previous_year))}
      #{teacher} #{pluralize(number_with_delimiter(candidates_recruited(current_cycle_period, current_year)), 'total candidate')} recruited | This point last cycle we had #{number_with_delimiter(candidates_recruited(previous_cycle_period, previous_year))}

      _Please note these numbers are as of 5pm and are not to be used for reporting purposes_

      :wave: Have a good weekend all
    MARKDOWN
  end

  def candidate_signups(period)
    Candidate.where(created_at: period).count
  end

  def applications_begun(period, year, phase)
    ApplicationForm.where(created_at: period, recruitment_cycle_year: year, phase: phase).count
  end

  def applications_submitted(period, year)
    ApplicationForm.where(submitted_at: period, recruitment_cycle_year: year).count
  end

  def offers_made(period, year)
    Offer.joins(:application_choice).where('application_choice.current_recruitment_cycle_year': year, created_at: period).count
  end

  def candidates_recruited(period, year)
    ApplicationChoice.where(recruited_at: period, current_recruitment_cycle_year: year).count
  end

  def rejections_issued(period, year)
    ApplicationChoice.where(rejected_at: period, current_recruitment_cycle_year: year).count
  end

  def rbd_count(period, year)
    ApplicationChoice.where(rejected_at: period, current_recruitment_cycle_year: year).where(rejected_by_default: true).count
  end

private

  def previous_cycle_period
    cycle_started = CycleTimetable.apply_opens(previous_year)
    cycle_started..CycleTimetable.this_working_day_last_cycle
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
