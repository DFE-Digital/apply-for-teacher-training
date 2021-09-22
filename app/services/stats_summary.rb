class StatsSummary
  include ActionView::Helpers::TextHelper

  def as_slack_message
    <<~MARKDOWN
      *Today on Apply*

      :email: #{pluralize(applications_submitted, 'application')} submitted
      :#{rand(2) == 1 ? 'wo' : nil}man-tipping-hand: #{pluralize(offers_made, 'offer')} made
      :#{rand(2) == 1 ? 'wo' : nil}man-gesturing-no: #{pluralize(rejections_issued, 'rejection')} issued#{rejections_issued.positive? ? ", of which #{pluralize(rbd_count, 'was')} RBD" : nil}
      :handshake: #{pluralize(candidates_recruited, 'candidate')} recruited
    MARKDOWN
  end

  def applications_submitted
    ApplicationForm.where('submitted_at > ?', beginning_of_period).count
  end

  def offers_made
    Offer.where('created_at > ?', beginning_of_period).count
  end

  def candidates_recruited
    ApplicationChoice.where('recruited_at > ?', beginning_of_period).count
  end

  def rejections_issued
    ApplicationChoice.where('rejected_at > ?', beginning_of_period).count
  end

  def rbd_count
    ApplicationChoice.where('rejected_at > ?', beginning_of_period).where(rejected_by_default: true).count
  end

private

  def beginning_of_period
    Time.zone.now.beginning_of_day
  end
end
