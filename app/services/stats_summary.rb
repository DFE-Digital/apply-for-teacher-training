class StatsSummary
  include ActionView::Helpers::TextHelper

  def as_slack_message
    <<~MARKDOWN
      *Today on Apply*
      _Please note these numbers are as of 5pm and are not to be used for reporting purposes_

      :wave: #{pluralize(candidate_signups(today), 'candidate signup')} | #{candidate_signups(this_day_last_year)} last cycle
      :pencil: #{pluralize(applications_begun(today), 'application')} begun | #{applications_begun(this_day_last_year)} last cycle
      :#{mailbox_emoji(applications_submitted(today))}: #{pluralize(applications_submitted(today), 'application')} submitted | #{applications_submitted(this_day_last_year)} last cycle
      :#{rand(2) == 1 ? 'wo' : nil}man-tipping-hand: #{pluralize(offers_made(today), 'offer')} made | #{offers_made(this_day_last_year)} last cycle
      :#{rand(2) == 1 ? 'wo' : nil}man-gesturing-no: #{pluralize(rejections_issued(today), 'rejection')} issued#{rejections_issued(today).positive? ? ", of which #{pluralize(rbd_count(today), 'was')} RBD" : nil} | #{rejections_issued(this_day_last_year)} last cycle
      :handshake: #{pluralize(candidates_recruited(today), 'candidate')} recruited | #{candidates_recruited(this_day_last_year)} last cycle
    MARKDOWN
  end

  def candidate_signups(period)
    Candidate.where(created_at: period).count
  end

  def applications_begun(period)
    ApplicationForm.where(created_at: period).count
  end

  def applications_submitted(period)
    ApplicationForm.where(submitted_at: period).count
  end

  def offers_made(period)
    Offer.where(created_at: period).count
  end

  def candidates_recruited(period)
    ApplicationChoice.where(recruited_at: period).count
  end

  def rejections_issued(period)
    ApplicationChoice.where(rejected_at: period).count
  end

  def rbd_count(period)
    ApplicationChoice.where(rejected_at: period).where(rejected_by_default: true).count
  end

private

  def today
    Time.zone.now.beginning_of_day..Time.zone.now
  end

  def this_day_last_year
    CycleTimetable.this_working_day_last_cycle.beginning_of_day..CycleTimetable.this_working_day_last_cycle
  end

  def mailbox_emoji(message_count)
    message_count.zero? ? 'mailbox_with_no_mail' : 'mailbox_with_mail'
  end
end
