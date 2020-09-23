class DeferOffer
  include ActiveModel::Validations

  def initialize(actor:, application_choice:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
  end

  def save
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).defer_offer!
      @application_choice.update(offer_deferred_at: Time.zone.now)
    end

    CandidateMailer.deferred_offer(@application_choice).deliver_later
    StateChangeNotifier.call(:defer_offer, application_choice: @application_choice)

    true
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
