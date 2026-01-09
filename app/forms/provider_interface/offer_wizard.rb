module ProviderInterface
  class OfferWizard
    include Wizard
    include Wizard::PathHistory

    INITIAL_STEP = :select_option
    FINAL_STEPS = %i[conditions check].freeze
    CHANGE_OFFER_STEPS = %i[providers courses study_modes locations].freeze
    SKE_STEPS = %i[ske_requirements ske_reason ske_length].freeze

    MAX_FURTHER_CONDITIONS = OfferValidations::MAX_CONDITIONS_COUNT - OfferCondition::STANDARD_CONDITIONS.length

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode,
                  :standard_conditions, :further_condition_attrs, :decision,
                  :path_history,
                  :provider_user_id, :application_choice_id,
                  :structured_conditions_attrs
    attr_reader :ske_conditions
    attr_writer :require_references, :references_description

    validates :decision, presence: true, on: %i[select_option]
    validates :course_option_id, presence: true, on: %i[locations save]
    validates :study_mode, presence: true, on: %i[study_modes save]
    validates :course_id, presence: true, on: %i[courses save]
    validates :require_references, inclusion: { in: [1, 0] }, on: %i[conditions]
    validates :references_description, presence: true, on: %i[conditions], if: -> { require_references? }

    validate :ske_conditions_are_valid, if: :ske_required?, on: SKE_STEPS
    validate :further_conditions_valid, on: %i[conditions]
    validate :max_conditions_length, on: %i[conditions]

    validate :course_option_details, if: :course_option_id, on: :save

    def self.build_from_application_choice(state_store, application_choice, options = {})
      course_option = application_choice.current_course_option

      attrs = {
        application_choice_id: application_choice.id,
        course_id: course_option.course.id,
        course_option_id: course_option.id,
        provider_id: course_option.provider.id,
        study_mode: course_option.study_mode,
        decision: :default,
        standard_conditions: standard_conditions_from(application_choice.offer),
        further_condition_attrs: further_condition_attrs_from(application_choice.offer),
        ske_conditions: ske_conditions_from(application_choice.offer),
        require_references: require_references_from(application_choice.offer),
        references_description: references_description_from(application_choice.offer),
      }.merge(options)

      new(state_store, attrs)
    end

    def self.require_references_from(offer)
      required = reference_condition(offer)&.required
      if required
        '1'
      elsif offer&.offered_at.blank? && required.nil?
        nil
      else
        '0'
      end
    end

    def self.references_description_from(offer)
      reference_condition(offer)&.description
    end

    def self.reference_condition(offer)
      offer&.reference_condition
    end

    def require_references
      @require_references&.to_i
    end

    def require_references?
      @require_references.present? && require_references.nonzero?.present?
    end

    def references_description
      return if require_references&.zero?

      @references_description
    end

    def conditions
      @conditions = (standard_conditions + further_condition_models.map(&:text)).compact_blank
    end

    def conditions_to_render(references: true)
      rendered_conditions = further_condition_models.map do |condition|
        TextCondition.new(details: { description: condition.text }, status: 'pending')
      end

      return rendered_conditions unless references

      rendered_conditions.push(reference_condition).compact
    end

    def reference_condition
      return unless require_references?

      ReferenceCondition.new(
        required: require_references?,
        description: references_description,
      )
    end

    def course_option
      CourseOption.find_by(id: course_option_id)
    end

    def ske_conditions_attributes=(attributes)
      if ske_standard_course?
        attributes.each_value do |attrs|
          ske_conditions.first.assign_attributes(attrs)
        end
      elsif language_course?
        ske_conditions.each do |ske_condition|
          attrs = attributes.values.find { |hash| hash['subject'] == ske_condition.subject }

          if attrs.blank?
            raise "Could not find attributes for #{ske_condition.subject} in #{attributes.inspect}"
          end

          ske_condition.assign_attributes(attrs)
        end
      end
    end

    def ske_conditions=(conditions)
      if conditions.nil?
        @ske_conditions = nil
        return
      end

      @ske_conditions = if conditions.first.is_a?(SkeCondition)
                          conditions
                        else
                          conditions.map { |sc| SkeCondition.new(sc) }
                        end
    end

    def next_step(step = current_step)
      return unless (index = steps.index(step.to_sym))
      return :conditions if ske_conditions.blank? && step.to_sym == :ske_requirements

      new_step = steps[index + 1]

      if (only_option = only_option_for_step(new_step))
        save_option(only_option)
        next_step(new_step)
      else
        new_step
      end
    end

    def ske_required?
      !undergraduate_course? && (language_course? || ske_standard_course? || Array(ske_conditions).any?)
    end

    def undergraduate_course?
      course_option&.course&.undergraduate?
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

    def further_condition_models
      @_further_condition_models ||= further_condition_attrs.map do |index, params|
        OfferConditionField.new(id: index.to_i, text: params['text'], condition_id: params['condition_id'])
      end
    end

    def max_number_of_further_conditions?
      further_condition_attrs.length >= MAX_FURTHER_CONDITIONS
    end

    def add_empty_condition
      return if max_number_of_further_conditions?

      further_condition_attrs.merge!(further_condition_attrs.length.to_s => { 'text' => '' })
      save_state!
    end

    def remove_condition(condition_id)
      further_condition_attrs.delete(condition_id)
      further_condition_attrs.transform_keys!.with_index { |_, index| index.to_s }
      save_state!
    end

    def remove_empty_conditions!
      further_condition_attrs.reject! { |_, condition| condition['text'].blank? }
      further_condition_attrs.transform_keys!.with_index { |_, index| index.to_s }
      save_state!
    end

    def available_changes?
      available_providers.length > 1 || available_courses.length > 1 ||
        available_study_modes.length > 1 || available_course_options.length > 1
    end

    def outdated_degree(application_choice, subject)
      graduation_cutoff_date = application_choice.current_course.ske_graduation_cutoff_date
      subject ||= application_choice.current_course.subjects.first&.name

      I18n.t(
        'provider_interface.offer.ske_reasons.outdated_degree',
        degree_subject: subject,
        graduation_cutoff_date: graduation_cutoff_date.to_fs(:month_and_year),
      )
    end

    def structured_conditions
      [ske_conditions, reference_condition].compact.flatten
    end

    delegate :name, to: :subject, prefix: true

  private

    def subject
      course_option&.course&.subjects&.first || course.subjects.first # rubocop:disable Style/SafeNavigationChainLength
    end

    def subject_mapping
      subject&.code
    end

    def self.standard_conditions_from(offer)
      return OfferCondition::STANDARD_CONDITIONS if offer.blank?

      conditions = offer.non_structured_conditions_text
      conditions & OfferCondition::STANDARD_CONDITIONS
    end

    private_class_method :standard_conditions_from

    def self.further_condition_attrs_from(offer)
      return {} if offer.blank?

      further_conditions = offer.text_conditions.reject(&:standard_condition?)

      further_conditions.each_with_index.to_h do |condition, index|
        [index.to_s, { 'text' => condition.text, 'condition_id' => condition.id }]
      end
    end

    private_class_method :further_condition_attrs_from

    def self.ske_conditions_from(offer)
      offer&.ske_conditions&.to_a
    end

    private_class_method :ske_conditions_from

    def course_option_details
      OfferedCourseOptionDetailsCheck.new(provider_id:,
                                          course_id:,
                                          course_option_id:,
                                          study_mode:).validate!
    rescue OfferedCourseOptionDetailsCheck::InvalidStateError => e
      errors.add(:base, e.message)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: provider_user,
        current_course: application_choice.current_course,
      )
    end

    def provider
      Provider.find(provider_id)
    end

    def course
      Course.find(course_id)
    end

    def provider_user
      ProviderUser.find(provider_user_id)
    end

    def application_choice
      ApplicationChoice.find(application_choice_id)
    end

    def available_providers
      query_service.available_providers
    end

    def available_courses
      query_service.available_courses(provider:)
    end

    def available_study_modes
      query_service.available_study_modes(course:)
    end

    def available_course_options
      query_service.available_course_options(course:, study_mode:)
    end

    def state_excluded_attributes
      %w[state_store errors validation_context query_service wizard_path_history _further_condition_models context_for_validation]
    end

    def further_conditions_valid
      further_condition_models.each do |model|
        model.valid?
        model.errors.each do |error|
          field_name = "further_conditions[#{model.id}][#{error.attribute}]"
          self.class.send(:define_method, field_name) { error.message }
          errors.add(field_name, error.message)
        end
      end
    end

    def max_conditions_length
      return unless (further_condition_models.count + standard_conditions.compact_blank.length) > OfferValidations::MAX_CONDITIONS_COUNT

      errors.add(:base, :exceeded_max_conditions, count: OfferValidations::MAX_CONDITIONS_COUNT)
    end

    def sanitize_attrs(attrs)
      if !last_saved_state.empty? && attrs[:course_id].present? && last_saved_state['course_id'].present? && last_saved_state['course_id'] != attrs[:course_id]
        attrs.merge!(study_mode: nil, course_option_id: nil)
      end
      attrs
    end

    def sanitize_last_saved_state(state, attrs)
      # We need to change attrs to a hash as it is an ActionController::Parameters object, to avoid setting the value to an un-permitted param
      if !state.empty? && attrs.to_h.key?('further_condition_attrs') && state['further_condition_attrs'] != attrs.to_h['further_condition_attrs']
        state['further_condition_attrs'] = {}
      end

      state
    end

    def steps
      case decision.to_sym
      when :change_offer
        if ske_required?
          [INITIAL_STEP, CHANGE_OFFER_STEPS, SKE_STEPS, FINAL_STEPS].flatten
        else
          [INITIAL_STEP] + CHANGE_OFFER_STEPS + FINAL_STEPS
        end
      when :make_offer
        if ske_required?
          [INITIAL_STEP] + SKE_STEPS + FINAL_STEPS
        else
          [INITIAL_STEP] + FINAL_STEPS
        end
      else
        []
      end
    end

    def only_option_for_step(step)
      case step.to_sym
      when :providers
        { provider_id: available_providers.first.id } if available_providers.length == 1
      when :courses
        { course_id: available_courses.first.id } if available_courses.length == 1
      when :study_modes
        { study_mode: available_study_modes.first } if available_study_modes.length == 1
      when :locations
        { course_option_id: available_course_options.first.id } if available_course_options.length == 1
      end
    end

    def save_option(option)
      assign_attributes(last_saved_state.deep_merge(option))
      save_state!
    end

    def ske_conditions_are_valid
      if at_or_past(:ske_requirements)
        validate_ske_conditions(:subject)
        validate_language_count if language_course?
      end

      validate_ske_conditions(:reason) if at_or_past(:ske_reason)

      if at_or_past(:ske_length)
        validate_ske_conditions(:length)
        validate_combined_ske_length if multiple_ske_conditions?
      end
    end

    def at_or_past(step)
      steps.index(step.to_sym) <= steps.index(current_step.to_sym)
    end

    def validate_ske_conditions(context)
      ske_conditions.each_with_index do |ske_condition, index|
        ske_condition.validate(context)

        ske_condition.errors.each do |error|
          next if error.attribute == :offer

          field_name = "ske_conditions_attributes[#{index}][#{error.attribute}]"
          errors.add(field_name, error.message)
        end
      end
    end

    def validate_combined_ske_length
      if SkeCondition.no_conditions_meet_minimum_length_criteria?(ske_conditions)
        errors.add(:base, :must_have_at_least_one_8_week_ske_course)
      end
    end

    def validate_language_count
      if ske_conditions.length > SkeCondition::MAX_SKE_LANGUAGES
        errors.add(:base, :too_many, count: SkeCondition::MAX_SKE_LANGUAGES)
      end
    end

    def multiple_ske_conditions?
      ske_conditions.length > 1
    end
  end
end
