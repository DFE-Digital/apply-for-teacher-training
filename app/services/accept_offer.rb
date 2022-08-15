class AcceptOffer
  include ActiveModel::Model
  attr_accessor :application_choice

  validate :references_completed, if: :new_reference_flow?

  def save!
    return unless valid?

    if FeatureFlag.active?(:unconditional_offers_via_api) && unconditional_offer?
      return AcceptUnconditionalOffer.new(application_choice: application_choice).save!
    end

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(application_choice).accept!
      application_choice.update!(accepted_at: Time.zone.now)

      withdraw_and_decline_associated_application_choices!
    end

    if application_form.show_new_reference_flow?
      application_form.application_references.includes([:application_form]).not_requested_yet.each do |reference|
        RequestReference.new.call(reference)
      end
    end

    NotificationsList.for(application_choice, event: :offer_accepted, include_ratifying_provider: true).each do |provider_user|
      ProviderMailer.offer_accepted(provider_user, application_choice).deliver_later
    end

    CandidateMailer.offer_accepted(application_choice).deliver_later
  end

protected

  def withdraw_and_decline_associated_application_choices!
    StateChangeNotifier.disable_notifications do
      other_application_choices_with_offers.each do |application_choice|
        DeclineOffer.new(application_choice: application_choice).save!
      end

      application_choices_awaiting_provider_decision.each do |application_choice|
        WithdrawApplication.new(application_choice: application_choice).save!
      end
    end
  end

  def other_application_choices_with_offers
    application_choice
      .self_and_siblings
      .offer
      .where.not(id: application_choice.id)
  end

  def application_choices_awaiting_provider_decision
    application_choice
      .self_and_siblings
      .decision_pending
  end

  def new_reference_flow?
    application_form.show_new_reference_flow?
  end

  def references_completed
    errors.add(:base, :incomplete_references) unless application_form.complete_references_information?
  end

  delegate :unconditional_offer?, :application_form, to: :application_choice
end
