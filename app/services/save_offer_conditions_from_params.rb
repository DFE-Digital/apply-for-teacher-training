class SaveOfferConditionsFromParams
  attr_reader :application_choice, :standard_conditions, :references_description, :further_condition_attrs, :structured_conditions, :support_action

  def initialize(application_choice:, standard_conditions:, further_condition_attrs:, references_description: nil, structured_conditions: [], support_action: false)
    @application_choice = application_choice
    @standard_conditions = standard_conditions & OfferCondition::STANDARD_CONDITIONS
    @references_description = references_description
    @further_condition_attrs = further_condition_attrs
    @structured_conditions = structured_conditions
    @support_action = support_action
  end

  def save
    ActiveRecord::Base.transaction do
      @offer = Offer.find_or_create_by(application_choice:)

      serialize_standard_conditions
      serialize_further_conditions
      serialize_structured_conditions
    end
  rescue ActiveRecord::RecordNotFound => e
    raise ValidationException, [e.message]
  end

  def conditions
    further_condition_attrs.values.map { |hash| hash['text'] } + standard_conditions
  end

private

  def serialize_structured_conditions
    return if support_action

    # Delete all current structured conditions if there is a change of course
    @offer.ske_conditions.destroy_all if @offer.ske_conditions.any?
    @offer.reference_condition.presence&.destroy

    return if structured_conditions.blank?

    structured_conditions.each do |structured_condition|
      structured_condition.offer = @offer
      structured_condition.save!
    end
  end

  def serialize_standard_conditions
    existing_standard_conditions = @offer.conditions.where(
      "details->'description' ?| array[:conditions]",
      conditions: OfferCondition::STANDARD_CONDITIONS,
    )

    standard_conditions.each do |text|
      existing_standard_conditions.find_by("details->>'description' = ?", text) ||
        existing_standard_conditions.create(type: 'TextCondition', details: { description: text })
    end
    conditions_to_destroy = existing_standard_conditions.where.not(
      "details->'description' ?| array[:conditions]",
      conditions: standard_conditions,
    )
    conditions_to_destroy.destroy_all
  end

  def serialize_further_conditions
    new_conditions = further_condition_attrs.each_value.map do |params|
      create_or_update_condition(params)
    end

    remove_deleted_conditions(new_conditions)
  end

  def remove_deleted_conditions(new_conditions)
    existing_condition_ids = further_condition_attrs.values.inject(new_conditions.map(&:id)) do |conditions, hash|
      conditions << hash['condition_id']
    end

    offer_further_conditions.includes(%i[application_choice offer]).where.not(id: existing_condition_ids).destroy_all
  end

  def create_or_update_condition(params)
    existing_condition = params['condition_id'].present? ? offer_further_conditions.find(params['condition_id']) : nil

    if existing_condition.blank?
      existing_condition = offer_further_conditions.create(type: 'TextCondition', details: { description: params['text'] })
    else
      existing_condition.update(description: params['text'])
    end

    existing_condition
  end

  def offer_further_conditions
    @offer_further_conditions ||= @offer.conditions.where.not(
      "details->'description' ?| array[:conditions]",
      conditions: OfferCondition::STANDARD_CONDITIONS,
    )
  end
end
