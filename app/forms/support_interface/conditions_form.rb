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

    CheckBoxOption = Struct.new(:value, :name)

    include ActiveModel::Model

    attr_accessor :application_choice, :standard_conditions, :references_description, :further_condition_attrs, :audit_comment_ticket, :ske_conditions, :ske_required

    validates :application_choice, presence: true
    validates :audit_comment_ticket, presence: true
    validate :condition_count_valid
    validate :further_conditions_lengths_valid
    validates_with ZendeskUrlValidator
    validate :ske_conditions_are_valid

    def self.build_from_application_choice(application_choice, attrs = {})
      attrs = {
        application_choice:,
        standard_conditions: standard_conditions_from(application_choice.offer),
        references_description: references_description_from(application_choice.offer),
        further_condition_attrs: further_condition_attrs_from(application_choice.offer),
        ske_conditions: ske_conditions_from(application_choice.offer),
      }.merge(attrs)

      new(attrs).tap(&:add_slot_for_new_condition)
    end

    def self.build_from_params(application_choice, params)
      attrs = {
        standard_conditions: params['standard_conditions'] || [],
        references_description: params['references_description'] || '',
        audit_comment_ticket: params['audit_comment_ticket'],
        further_condition_attrs: params['further_conditions'] || {},
        ske_conditions: params['ske_conditions']&.select { |_, ske_attrs| ActiveModel::Type::Boolean.new.cast(ske_attrs['ske_required']) } || {},
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
        SkeConditionField.new(attrs.merge(id: index, ske_required: true))
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
      application_choice.current_course&.subjects&.first
    end

    def cutoff_date
      application_choice.current_course.ske_graduation_cutoff_date
    end

    def ske_length_options
      SkeCondition::SKE_LENGTHS.map { |length| CheckBoxOption.new(length.to_s, "#{length} weeks") }
    end

    def ske_reason_options(subject:)
      [
        CheckBoxOption.new(SkeCondition::DIFFERENT_DEGREE_REASON, different_degree_reason_label(subject:)),
        CheckBoxOption.new(SkeCondition::OUTDATED_DEGREE_REASON, outdated_degree_reason_label(subject:)),
      ]
    end

    def standard_ske_condition
      if ske_condition_models.present?
        ske_condition_models.first
      else
        SkeConditionField.new(id: 0, subject: subject_name, subject_type: 'standard')
      end
    end

    def ske_condition_language_course_model_for(language, index)
      ske_condition_models.find do |ske|
        ske.subject == language
      end.presence || SkeConditionField.new(id: index, subject: language, subject_type: 'language')
    end

    def ske_course?
      language_course? || ske_standard_course? || Array(ske_conditions).any?
    end

    def language_course?
      subject_mapping.in?(Subject::SKE_LANGUAGE_COURSES)
    end

    def physics_course?
      subject_mapping.in?(Subject::SKE_PHYSICS_COURSES)
    end

    def ske_standard_course?
      subject_mapping.in?(Subject::SKE_STANDARD_COURSES)
    end

    def subject_mapping
      subject&.code
    end

  private

    def different_degree_reason_label(subject:)
      I18n.t(
        'provider_interface.offer.ske_reasons.different_degree',
        degree_subject: subject,
      )
    end

    def outdated_degree_reason_label(subject:)
      I18n.t(
        'provider_interface.offer.ske_reasons.outdated_degree',
        degree_subject: subject,
        graduation_cutoff_date: cutoff_date.to_fs(:month_and_year),
      )
    end

    def self.standard_conditions_from(offer)
      return [] if offer.blank?

      conditions = offer.non_structured_conditions_text
      conditions & OfferCondition::STANDARD_CONDITIONS
    end

    def self.further_condition_attrs_from(offer)
      return {} if offer.blank?

      further_conditions = offer.text_conditions.reject(&:standard_condition?)

      further_conditions.each_with_index.to_h do |condition, index|
        [index.to_s, { 'text' => condition.text, 'condition_id' => condition.id }]
      end
    end

    def self.references_description_from(offer)
      return '' if offer.blank? || offer&.reference_condition.blank?

      condition = offer.reference_condition

      condition.details['description']
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

    private_class_method :standard_conditions_from, :further_condition_attrs_from, :ske_conditions_from, :references_description_from

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
        references_description: references_description,
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
      conditions = ske_conditions.values.map do |ske_condition_attrs|
        SkeCondition.new(
          ske_condition_attrs.slice(
            *%w[subject subject_type length reason],
          ).merge('graduation_cutoff_date' => cutoff_date),
        )
      end

      if references_description.present?
        conditions << ReferenceCondition.new(
          required: true,
          description: references_description,
        )
      end

      conditions
    end

    def ske_conditions_are_valid
      validate_ske_conditions
      validate_language_count if language_course?
      validate_combined_ske_length if multiple_ske_conditions?
    end

    def validate_combined_ske_length
      if SkeCondition.no_conditions_meet_minimum_length_criteria?(structured_conditions_to_save)
        errors.add(:base, :must_have_at_least_one_8_week_ske_course)
      end
    end

    def validate_language_count
      if ske_conditions.length > SkeCondition::MAX_SKE_LANGUAGES
        errors.add(:base, :too_many, count: SkeCondition::MAX_SKE_LANGUAGES)
      end
    end

    def multiple_ske_conditions?
      ske_conditions.many?
    end

    def validate_ske_conditions
      structured_conditions_to_save.each_with_index do |ske_condition, index|
        ske_condition.validate

        ske_condition.errors.each do |error|
          next if error.attribute == :offer

          field_name = "ske_conditions_attributes[#{index}][#{error.attribute}]"
          errors.add(field_name, error.message)
        end
      end
    end
  end
end
