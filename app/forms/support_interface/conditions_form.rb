module SupportInterface
  class ConditionsForm
    class OfferConditionField
      include ActiveModel::Model

      attr_accessor :id, :text, :condition_id

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

    attr_accessor :application_choice, :standard_conditions, :further_condition_attrs, :audit_comment_ticket

    validates :application_choice, presence: true
    validates :audit_comment_ticket, presence: true
    validates :audit_comment_ticket, format: { with: /\A((http|https):\/\/)?(www.)?becomingateacher.zendesk.com\/agent\/tickets\// }
    validate :condition_count_valid
    validate :further_conditions_lengths_valid

    def self.build_from_application_choice(application_choice, attrs = {})
      attrs = {
        application_choice: application_choice,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_condition_attrs: further_condition_attrs_from(application_choice.offer),
      }.merge(attrs)

      new(attrs).tap(&:add_slot_for_new_condition)
    end

    def self.build_from_params(application_choice, params)
      attrs = {
        standard_conditions: params['standard_conditions'] || [],
        audit_comment_ticket: params['audit_comment_ticket'],
        further_condition_attrs: params['further_conditions'] || {},
      }

      build_from_application_choice(application_choice, attrs)
    end

    def add_slot_for_new_condition
      return if further_condition_attrs.length + 1 > OfferValidations::MAX_CONDITIONS_COUNT

      self.further_condition_attrs = further_conditions_to_save
      further_condition_attrs.merge!({ further_condition_attrs.length.to_s => { 'text' => '' } })
    end

    def further_condition_models
      @further_condition_models ||= further_condition_attrs.map do |index, params|
        OfferConditionField.new(id: index.to_i, text: params['text'], condition_id: params['condition_id'])
      end
    end

    def conditions_empty?
      conditions_count.zero?
    end

    def save
      return false unless valid?

      UpdateAcceptedOfferConditions.new(
        application_choice: application_choice,
        update_conditions_service: update_conditions_service,
        audit_comment_ticket: audit_comment_ticket,
      ).save!
    end

  private

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer.conditions_text
      conditions & MakeOffer::STANDARD_CONDITIONS
    end

    def self.further_condition_attrs_from(offer)
      return {} if offer.blank?

      further_conditions = offer.conditions.reject do |condition|
        MakeOffer::STANDARD_CONDITIONS.include?(condition.text)
      end

      further_conditions.each_with_index.to_h do |condition, index|
        [index.to_s, { 'text' => condition.text, 'condition_id' => condition.id }]
      end
    end

    private_class_method :standard_conditions_from, :further_condition_attrs_from

    def condition_count_valid
      if conditions_count > OfferValidations::MAX_CONDITIONS_COUNT
        errors.add(:base, :exceeded_max_conditions, count: OfferValidations::MAX_CONDITIONS_COUNT)
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

    def update_conditions_service
      ::SaveOfferConditionsFromParams.new(
        application_choice: application_choice,
        standard_conditions: standard_conditions.compact_blank,
        further_condition_attrs: further_conditions_to_save,
      )
    end

    def further_conditions_to_save
      further_condition_attrs.reject { |_, params| params['text'].blank? }
    end

    def conditions_count
      further_conditions_to_save.count + standard_conditions.compact_blank.length
    end
  end
end
