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
          application_choice.update!(
            reject_by_default_at: new_rbd_date,
            status: :awaiting_provider_decision,
            rejected_by_default: false,
            rejected_at: nil,
          )

          application_choice.self_and_siblings.where(status: :offer).update_all(
            decline_by_default_at: nil,
            decline_by_default_days: nil,
          )
        end
    end
  end
end
