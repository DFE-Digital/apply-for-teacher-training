class SendCandidateOneLoginIsComingEmailWorker
  include Sidekiq::Worker

  def perform
    return if should_not_perform?

    BatchDelivery.new(relation:, batch_size: 200).each do |batch_time, application_forms|
      SendOneLoginIsComingEmailBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
    end
  end

  def relation
    ApplicationForm
      .current_cycle
      .joins(:candidate)
      .merge(Candidate.for_marketing_or_nudge_emails)
      .has_not_received_email('candidate_mailer', 'one_login_is_coming')
      .distinct
  end

private

  def should_not_perform?
    FeatureFlag.active?(:one_login_candidate_sign_in) || OneLogin.bypass?
  end
end

class SendOneLoginIsComingEmailBatchWorker
  include Sidekiq::Worker

  def perform(application_form_ids)
    ApplicationForm.where(id: application_form_ids).find_each do |application_form|
      CandidateMailer.one_login_is_coming(application_form).deliver_later
    end
  end
end
