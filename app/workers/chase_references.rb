class ChaseReferences
  include Sidekiq::Worker

  REFEREE_CHASERS = [
    {
      after: 7.days,
      email: :reference_request_chaser_email,
      type: :referee_reference_request,
      old_type: :reference_request,
      include_application_form: true,
    },
    {
      after: 14.days,
      email: :reference_request_chaser_email,
      type: :reminder_reference_nudge,
      include_application_form: true,
    },
    {
      after: 28.days,
      email: :reference_request_chase_again_email,
      type: :referee_follow_up_missing_references,
      old_type: :follow_up_missing_references,
    },
  ].freeze

  CANDIDATE_CHASERS = [
    {
      after: 9.days,
      email: :chase_reference,
      type: :candidate_reference_request,
      old_type: :reference_request,
    },
    {
      after: 16.days,
      email: :new_referee_request,
      type: :reference_replacement,
      extra_params: { reason: :not_responded },
    },
    {
      after: 30.days,
      email: :chase_reference_again,
      type: :candidate_follow_up_missing_references,
      old_type: :follow_up_missing_references,
    },
  ].freeze

  def perform
    REFEREE_CHASERS.each { |chaser| send_chaser(chaser, mailer: RefereeMailer) }
    CANDIDATE_CHASERS.each { |chaser| send_chaser(chaser, mailer: CandidateMailer) }
  end

private

  def send_chaser(chaser, mailer:)
    chase_referee_by = chaser[:after].before(Time.zone.now)
    chaser_type = chaser[:type].to_s
    previous_chaser_type = chaser_type.sub(/^candidate_|^referee_/, '')
    rejected_chased_ids = ChaserSent.where(
      chaser_type: [chaser_type, previous_chaser_type].uniq,
    ).select(:chased_id)

    references = GetRefereesToChase.new(chase_referee_by:, rejected_chased_ids:).call

    references.each do |reference|
      deliver_email(reference: reference, chaser: chaser, mailer: mailer)

      ChaserSent.create!(chased: reference, chaser_type: chaser[:type])
    end
  end

  def deliver_email(reference:, chaser:, mailer:)
    email_method = mailer.method(chaser[:email])

    if chaser[:extra_params].present?
      email_method.call(reference, **chaser[:extra_params]).deliver_later
    elsif chaser[:include_application_form].present?
      email_method.call(reference.application_form, reference).deliver_later
    else
      email_method.call(reference).deliver_later
    end
  end
end
