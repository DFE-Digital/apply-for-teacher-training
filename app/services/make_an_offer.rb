class MakeAnOffer
  attr_accessor :offer_conditions

  include ActiveModel::Validations

  MAX_CONDITIONS_COUNT = 20
  MAX_CONDITION_LENGTH = 255

  validate :validate_offer_conditions

  def initialize(application_choice:, offer_conditions: nil)
    @application_choice = application_choice
    @offer_conditions = offer_conditions
  end

  def save
    return unless valid?

    ApplicationStateChange.new(application_choice).make_offer!
    application_choice.offer = { 'conditions' => (@offer_conditions || []) }

    application_choice.offered_at = Time.now
    application_choice.save!

    SetDeclineByDefault.new(application_form: application_choice.application_form).call
    StateChangeNotifier.call(:make_an_offer, application_choice: application_choice)
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end

private

  attr_reader :application_choice

  def validate_offer_conditions
    return if @offer_conditions.blank?

    unless @offer_conditions.is_a?(Array)
      errors.add(:offer_conditions, 'must be an array')
      return
    end

    errors.add(:offer_conditions, "has over #{MAX_CONDITIONS_COUNT} elements") if @offer_conditions.count > MAX_CONDITIONS_COUNT
    errors.add(:offer_conditions, "has a condition over #{MAX_CONDITION_LENGTH} chars in length") if @offer_conditions.any? { |c| c.length > MAX_CONDITION_LENGTH }
  end
end
