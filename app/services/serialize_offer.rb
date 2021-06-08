class SerializeOffer
  attr_reader :application_choice, :standard_conditions, :further_condition_attrs

  def initialize(application_choice:, standard_conditions:, further_condition_attrs:)
    @application_choice = application_choice
    @standard_conditions = standard_conditions
    @further_condition_attrs = further_condition_attrs
  end

  def save
    @offer = Offer.find_or_create_by(application_choice: application_choice)

    serialize_standard_conditions
    serialize_further_conditions
  end

  def serialize_standard_conditions
    existing_standard_conditions = @offer.conditions.where(text: MakeOffer::STANDARD_CONDITIONS)

    standard_conditions.each do |text|
      existing_standard_conditions.find_or_create_by(text: text)
    end
    conditions_to_destroy = existing_standard_conditions.where.not(text: standard_conditions)
    conditions_to_destroy.destroy_all
  end

  def serialize_further_conditions
    existing_further_conditions = @offer.conditions.where.not(text: MakeOffer::STANDARD_CONDITIONS)

    further_condition_attrs.values.each do |hash|
      condition_id = hash['condition_id']
      condition_text = hash['text']

      if condition_id.blank?
        @offer.conditions.create(text: condition_text)
      else
        condition = existing_further_conditions.find(condition_id)
        condition.update(text: condition_text)
      end
    end

    remaining_ids = further_condition_attrs.values.filter_map { |hash| hash['condition_id'].presence }
    @offer.conditions.where.not(id: remaining_ids).destroy_all
  end

  def conditions
    further_condition_attrs.values.map { |hash| hash['text'] } + standard_conditions
  end
end
