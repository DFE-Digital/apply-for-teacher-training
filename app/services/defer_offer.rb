class DeferOffer
  include ActiveModel::Model
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option

  def initialize(actor:, application_choice:)
    @actor = actor
    @application_choice = application_choice
    @course_option = application_choice.current_course_option
  end

  def save!
    auth.assert_can_make_decisions!(application_choice:, course_option:)

    audit(actor) do
      previous_status = application_choice.status

      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(application_choice).defer_offer!
        application_choice.update!(
          status_before_deferral: previous_status,
          offer_deferred_at: Time.zone.now,
        )
      end

      CandidateMailer.deferred_offer(application_choice).deliver_later
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor:)
  end
end
