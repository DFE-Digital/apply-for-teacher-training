module SupportInterface
  class ConditionsForm
    class OfferConditionField
      include ActiveModel::Model

      attr_accessor :id, :text

      validate :validate_length

      def validate_length
        if id.zero?
          errors.add(:text, :too_long, index: id + 1, limit: OfferValidations::MAX_CONDITION_1_LENGTH) if text.length > OfferValidations::MAX_CONDITION_1_LENGTH
        elsif text.length > OfferValidations::MAX_CONDITION_LENGTH
          errors.add(:text, :too_long, index: id + 1, limit: OfferValidations::MAX_CONDITION_LENGTH)
        end
      end
    end

    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :further_conditions, :audit_comment_ticket

    MAX_FURTHER_CONDITIONS = OfferValidations::MAX_CONDITIONS_COUNT

    validates :application_choice, presence: true
    validates :audit_comment_ticket, presence: true
    validates :audit_comment_ticket, format: { with: /\A((http|https):\/\/)?(www.)?becomingateacher.zendesk.com\/agent\/tickets\// }
    validate :condition_count_valid
    validate :further_conditions_lengths_valid

    def self.build_from_application_choice(application_choice, attrs = {})
      attrs = {
        application_choice: application_choice,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_conditions: further_conditions_from(application_choice.offer),
      }.merge(attrs)

      new(attrs).tap(&:add_slots_for_new_conditions)
    end

    def self.build_from_params(application_choice, params)
      attrs = {
        standard_conditions: params['standard_conditions'] || [],
        audit_comment_ticket: params['audit_comment_ticket'],
        further_conditions: params['further_conditions']&.values&.map { |v| v['text'] } || [],
      }

      form = build_from_application_choice(application_choice, attrs)
      form.add_slots_for_new_conditions
      form
    end

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer.conditions_text
      conditions & MakeOffer::STANDARD_CONDITIONS
    end

    def self.further_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer.conditions_text
      conditions - MakeOffer::STANDARD_CONDITIONS
    end

    def add_slots_for_new_conditions
      further_condition_count = (further_conditions&.reject(&:blank?)&.count || 0)
      number_of_conditions_to_display = [
        further_condition_count + 1,
        MAX_FURTHER_CONDITIONS,
      ].min

      self.further_conditions = number_of_conditions_to_display.times.map do |index|
        existing_value = further_conditions && further_conditions[index]
        existing_value.presence || ''
      end
    end

    def further_condition_models
      @further_condition_models ||= further_conditions.map.with_index do |further_condition, index|
        OfferConditionField.new(id: index, text: further_condition)
      end
    end

    def condition_count_valid
      if all_conditions.count > OfferValidations::MAX_CONDITIONS_COUNT
        errors.add(:further_conditions, :too_many, limit: OfferValidations::MAX_CONDITIONS_COUNT)
      end
    end

    def further_conditions_lengths_valid
      further_condition_models.map(&:valid?).all?

      further_condition_models.each do |condition_model|
        condition_model.errors.each do |error|
          errors.add("further_conditions[#{condition_model.id}][#{error.attribute}]", error.message)
        end
      end
    end

    def save
      return false unless valid?

      UpdateAcceptedOfferConditions.new(
        application_choice: application_choice,
        conditions: all_conditions,
        audit_comment_ticket: audit_comment_ticket,
      ).save!
    end

    def all_conditions
      ((standard_conditions || []) + (further_conditions || [])).reject(&:blank?)
    end

    def conditions_empty?
      all_conditions.empty?
    end
  end
end
