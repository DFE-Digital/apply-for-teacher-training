class DeferOffer
  include ActiveModel::Model
  include ImpersonationAuditHelper

  def initialize(actor:, application_choice:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
  end

  def save!
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.current_course_option.id)

    audit(@auth.actor) do
      prior_status = @application_choice.status

      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(@application_choice).defer_offer!
        @application_choice.update!(
          status_before_deferral: prior_status,
          offer_deferred_at: Time.zone.now,
        )
      end

      CandidateMailer.deferred_offer(@application_choice).deliver_later
      StateChangeNotifier.call(:defer_offer, application_choice: @application_choice)
    end
  end
end
