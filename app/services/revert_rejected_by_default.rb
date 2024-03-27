class RevertRejectedByDefault
  attr_reader :ids, :new_rbd_date

  def initialize(ids:, new_rbd_date:)
    @ids = ids
    @new_rbd_date = new_rbd_date
  end

  def call
    Audited.audit_class.as_user('RevertRejectedByDefault worker') do
      ApplicationChoice
        .where(application_form_id: ids)
        .where(rejected_by_default: true)
        .find_each do |application_choice|
          statuses_for_form = application_choice.self_and_siblings.pluck(:status)

          # do not continue if the application has an accepted offer
          next if statuses_for_form.any? do |s|
            ApplicationStateChange.accepted.include?(s.to_sym)
          end

          application_choice.update!(
            reject_by_default_at: new_rbd_date,
            status: :awaiting_provider_decision,
            rejected_by_default: false,
            rejected_at: nil,
            rejection_reason: nil,
            structured_rejection_reasons: nil,
          )

          application_choice.self_and_siblings.where(status: :offer).update(
            decline_by_default_at: nil,
            decline_by_default_days: nil,
          )
        end

      ApplicationForm
        .where(id: ids)
        .find_each do |form|
          form.chasers_sent
            .where(chaser_type: :candidate_decision_request)
            .destroy_all
        end
    end
  end
end
