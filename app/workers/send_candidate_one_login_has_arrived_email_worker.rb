class SendCandidateOneLoginHasArrivedEmailWorker
  include Sidekiq::Worker

  def perform
    return if should_not_perform?

    BatchDelivery.new(relation:, batch_size: 200).each do |batch_time, application_forms|
      SendOneLoginHasArrivedEmailBatchWorker.perform_at(batch_time, application_forms.pluck(:id))
    end
  end

  def relation
    ApplicationForm
      .current_cycle
      .where(candidate_id: candidate_ids)
      .has_not_received_email('candidate_mailer', 'one_login_has_arrived')
      .distinct
  end

private

  def candidate_ids
    Candidate
      .for_marketing_or_nudge_emails
      .where.missing(:one_login_auth)
      .pluck(:id)
  end

  def should_not_perform?
    FeatureFlag.inactive?(:one_login_candidate_sign_in) || OneLogin.bypass?
  end
end

class SendOneLoginHasArrivedEmailBatchWorker
  include Sidekiq::Worker

  def perform(application_form_ids)
    ApplicationForm.where(id: application_form_ids).find_each do |application_form|
      CandidateMailer.one_login_has_arrived(application_form).deliver_later
    end
  end
end
