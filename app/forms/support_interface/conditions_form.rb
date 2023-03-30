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

    class SkeConditionField
      include ActiveModel::Model

      attr_accessor :id, :condition_id, :length, :reason, :subject, :subject_type, :ske_required, :graduation_cutoff_date
    end

    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :further_condition_attrs, :audit_comment_ticket, :ske_conditions, :ske_required

    validates :application_choice, presence: true
    validates :audit_comment_ticket, presence: true
    validate :condition_count_valid
    validate :further_conditions_lengths_valid
    validates_with ZendeskUrlValidator

    def self.build_from_application_choice(application_choice, attrs = {})
      attrs = {
        application_choice:,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_condition_attrs: further_condition_attrs_from(application_choice.offer),
        ske_conditions: ske_conditions_from(application_choice.offer),
      }.merge(attrs)

      new(attrs).tap(&:add_slot_for_new_condition)
    end

    def self.build_from_params(application_choice, params)
      attrs = {
        standard_conditions: params['standard_conditions'] || [],
        audit_comment_ticket: params['audit_comment_ticket'],
        further_condition_attrs: params['further_conditions'] || {},
        ske_conditions: params['ske_conditions']&.select { |_, ske_attrs| ske_attrs['ske_required'] == 'true' } || {},
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

    def ske_condition_models
      @ske_condition_models ||= ske_conditions.map do |index, attrs|
        SkeConditionField.new(attrs.merge(id: index))
      end
    end

    def conditions_empty?
      conditions_count.zero?
    end

    def save
      return false unless valid?

      UpdateAcceptedOfferConditions.new(
        application_choice:,
        update_conditions_service:,
        audit_comment_ticket:,
      ).save!
    end

    def subject_name
      subject&.name
    end

    def subject
      application_choice.course_option&.course&.subjects&.first
    end

    def cutoff_date
      application_choice.current_course.start_date - 5.years
    end

    def ske_length_options
      ProviderInterface::OfferWizard::SKE_LENGTHS.map { |length| OpenStruct.new(value: length.to_s, name: "#{length} weeks") }
    end

    def ske_reason_options
      [
        OpenStruct.new(value: SkeCondition::DIFFERENT_DEGREE_REASON, name: different_degree_reason_label),
        OpenStruct.new(value: SkeCondition::OUTDATED_DEGREE_REASON, name: outdated_degree_reason_label),
      ]
    end

    def standard_ske_condition
      if ske_condition_models.present?
        ske_condition_models.first
      else
        SkeConditionField.new(id: 0, subject: subject_name, subject_type: 'standard')
      end
    end

  private

    def different_degree_reason_label
      I18n.t(
        'provider_interface.offer.ske_reasons.different_degree',
        degree_subject: subject_name,
      )
    end

    def outdated_degree_reason_label
      I18n.t(
        'provider_interface.offer.ske_reasons.outdated_degree',
        degree_subject: subject_name,
        graduation_cutoff_date: cutoff_date.to_fs(:month_and_year),
      )
    end

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer.conditions_text
      conditions & OfferCondition::STANDARD_CONDITIONS
    end

    def self.further_condition_attrs_from(offer)
      return {} if offer.blank?

      further_conditions = offer.conditions.reject(&:standard_condition?)

      further_conditions.each_with_index.to_h do |condition, index|
        [index.to_s, { 'text' => condition.text, 'condition_id' => condition.id }]
      end
    end

    def self.ske_conditions_from(offer)
      return {} if offer.blank? || offer&.ske_conditions.blank?

      offer.ske_conditions.each_with_index.to_h do |condition, index|
        [
          index,
          {
            id: index,
            condition_id: condition.id,
            length: condition.length,
            reason: condition.reason,
            subject: condition.subject,
            subject_type: condition.subject_type,
            graduation_cutoff_date: condition.graduation_cutoff_date,
          },
        ]
      end
    end

    private_class_method :standard_conditions_from, :further_condition_attrs_from, :ske_conditions_from

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
        application_choice:,
        standard_conditions: standard_conditions.compact_blank,
        further_condition_attrs: further_conditions_to_save,
        structured_conditions: structured_conditions_to_save,
      )
    end

    def further_conditions_to_save
      further_condition_attrs.reject { |_, params| params['text'].blank? }
    end

    def conditions_count
      further_conditions_to_save.count + standard_conditions.compact_blank.length
    end

    def structured_conditions_to_save
      ske_conditions.values.map do |ske_condition_attrs|
        SkeCondition.new(
          ske_condition_attrs.slice(
            *%w[subject subject_type length reason],
          ).merge('graduation_cutoff_date' => cutoff_date),
        )
      end
    end
  end
end
