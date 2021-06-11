class SaveOfferConditionsFromParams
  attr_reader :application_choice, :standard_conditions, :further_condition_attrs

  def initialize(application_choice:, standard_conditions:, further_condition_attrs:)
    @application_choice = application_choice
    @standard_conditions = standard_conditions & MakeOffer::STANDARD_CONDITIONS
    @further_condition_attrs = further_condition_attrs
  end

  def save
    @offer = Offer.find_or_create_by(application_choice: application_choice)

    serialize_standard_conditions
    serialize_further_conditions
  end

  def conditions
    further_condition_attrs.values.map { |hash| hash['text'] } + standard_conditions
  end

private

  def serialize_standard_conditions
    existing_standard_conditions = @offer.conditions.where(text: MakeOffer::STANDARD_CONDITIONS)

    standard_conditions.each do |text|
      existing_standard_conditions.find_or_create_by(text: text)
    end
    conditions_to_destroy = existing_standard_conditions.where.not(text: standard_conditions)
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

    offer_further_conditions.where.not(id: existing_condition_ids).destroy_all
  end

  def create_or_update_condition(params)
    existing_condition = offer_further_conditions.find_by(id: params['condition_id'])

    if existing_condition.blank?
      existing_condition = offer_further_conditions.create(text: params['text'])
    else
      existing_condition.update(text: params['text'])
    end

    existing_condition
  end

  def offer_further_conditions
    @offer_further_conditions ||= @offer.conditions.where.not(text: MakeOffer::STANDARD_CONDITIONS)
  end
end
