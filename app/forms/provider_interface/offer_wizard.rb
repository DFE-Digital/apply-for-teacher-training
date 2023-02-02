module ProviderInterface
  class OfferWizard
    include Wizard
    include Wizard::PathHistory

    SKE_LENGTH = 8.step(by: 4).take(6).freeze
    SKE_LANGUAGES = [
      'French',
      'Spanish',
      'German',
      'ancient languages',
    ].freeze
    SKE_LANGUAGES_WITH_NO_SKE_REQUIRED_INCLUDED = [SKE_LANGUAGES, 'no'].flatten.freeze
    MAX_SKE_LANGUAGES = 2
    MAX_SKE_LENGTH = 36

    INITIAL_STEP = :select_option
    FINAL_STEPS = %i[conditions check].freeze
    CHANGE_OFFER_STEPS = %i[providers courses study_modes locations].freeze
    SKE_STEPS = %i[ske_requirements ske_reason ske_length].freeze

    MAX_FURTHER_CONDITIONS = OfferValidations::MAX_CONDITIONS_COUNT - OfferCondition::STANDARD_CONDITIONS.length

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode,
                  :standard_conditions, :further_condition_attrs, :decision,
                  :path_history,
                  :provider_user_id, :application_choice_id,
                  :ske_conditions, :ske_required,
                  :structured_conditions_attrs

    validates :decision, presence: true, on: %i[select_option]
    validates :course_option_id, presence: true, on: %i[locations save]
    validates :study_mode, presence: true, on: %i[study_modes save]
    validates :course_id, presence: true, on: %i[courses save]

    validate :ske_conditions_are_valid

    # validate :ske_languages_selected, on: %i[ske_requirements]
    # validate :no_languages_selected, on: %i[ske_requirements]
    # validate :ske_language_selected, on: %i[ske_requirements]

    # validates :ske_reason, presence: true, on: %i[ske_reason], unless: :language_course?
    # validate :ske_reasons_are_valid, on: %i[ske_reason], if: :language_course?

    # validates :ske_length, presence: true, on: %i[ske_length], unless: :language_course?
    # validate :ske_length_less_than_max_weeks, on: %i[ske_length]
    # validate :ske_language_length_1_presence, on: %i[ske_length], if: :language_course?
    # validate :ske_language_length_2_presence, on: %i[ske_length], if: :language_course?, unless: :one_language?

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
        # TODO
        structured_conditions_attrs: structured_condition_attrs_from(application_choice.offer),
      }.merge(options)

      new(state_store, attrs)
    end

    def conditions
      @conditions = (standard_conditions + further_condition_models.map(&:text)).compact_blank
    end

    def conditions_to_render
      conditions.map { |condition| OfferCondition.new(text: condition, status: 'pending') }
    end

    def course_option
      CourseOption.find(course_option_id)
    end

    def ske_conditions_attributes=(attributes)
      attributes.each do |_, attrs|
        self.ske_conditions << SkeCondition.new(attrs) if Array(attrs[:required]) == ['true']
      end
    end

    def ske_conditions=(conditions)
      if conditions.first.is_a?(SkeCondition)
        @ske_conditions = conditions
      else
        @ske_conditions =  conditions.map { |sc| SkeCondition.new(sc) }
      end
    end

    def next_step(step = current_step)
      return unless (index = steps.index(step.to_sym))

      new_step = steps[index + 1]

      if (only_option = only_option_for_step(new_step))
        save_option(only_option)
        next_step(new_step)
      else
        new_step
      end
    end

    def ske_required?
      return false if FeatureFlag.inactive?(:provider_ske)

      if language_course?
        ActiveModel::Type::Boolean.new.cast(ske_required).blank?
      else
        ske_conditions.any?
      end
    end

    def language_course?
      subject = course_option.course.subjects.first
      MinisterialReport::SUBJECT_CODE_MAPPINGS[subject&.code] == :modern_foreign_languages
    end

    def ske_languages
      Array(ske_requirements).compact_blank - ['no']
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

    def different_degree_option(application_choice, subject)
      subject ||= application_choice.current_course.subjects.first&.name

      I18n.t(
        'provider_interface.offer.ske_reasons.new.different_degree',
        degree_subject: subject,
      )
    end

    def outdated_degree(application_choice, subject)
      graduation_date = application_choice.current_course.start_date - 5.years
      subject ||= application_choice.current_course.subjects.first&.name

      I18n.t(
        'provider_interface.offer.ske_reasons.new.outdated_degree',
        degree_subject: subject,
        graduation_date: graduation_date.to_fs(:month_and_year),
      )
    end

    def structured_conditions
      # TODO
      return [] unless FeatureFlag.active?(:provider_ske)

      ske_conditions
    end

  private

    def self.standard_conditions_from(offer)
      return OfferCondition::STANDARD_CONDITIONS if offer.blank?

      conditions = offer.conditions_text
      conditions & OfferCondition::STANDARD_CONDITIONS
    end

    def self.structured_condition_attrs_from(offer)
      offer
    end

    private_class_method :standard_conditions_from

    def self.further_condition_attrs_from(offer)
      return {} if offer.blank?

      further_conditions = offer.conditions.reject(&:standard_condition?)

      further_conditions.each_with_index.to_h do |condition, index|
        [index.to_s, { 'text' => condition.text, 'condition_id' => condition.id }]
      end
    end

    private_class_method :further_condition_attrs_from

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
      %w[state_store errors validation_context query_service wizard_path_history _further_condition_models ]
    end

    def further_conditions_valid
      further_condition_models.each do |model|
        model.valid?
        model.errors.each do |error|
          field_name = "further_conditions[#{model.id}][#{error.attribute}]"
          errors.add(field_name, error.message)
        end
      end
    end

    def max_conditions_length
      return unless (further_condition_models.count + standard_conditions.compact_blank.length) > OfferValidations::MAX_CONDITIONS_COUNT

      errors.add(:base, :exceeded_max_conditions, count: OfferValidations::MAX_CONDITIONS_COUNT)
    end

    def sanitize_attrs(attrs)
      if !last_saved_state.empty? && attrs[:course_id].present? && last_saved_state['course_id'] != attrs[:course_id]
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

    def ske_languages_selected
      return if number_of_selected_ske_languages <= MAX_SKE_LANGUAGES

      errors.add(:ske_language_required, :too_many, count: MAX_SKE_LANGUAGES)
    end

    def no_languages_selected
      if number_of_selected_ske_languages > 1 && ske_language_required.include?('no')
        errors.add(:ske_language_required, :no_and_languages_selected)
      end
    end

    def number_of_selected_ske_languages
      Array(ske_language_required).compact_blank.count
    end

    def ske_length_less_than_max_weeks
      return if ske_language_length_1.to_i + ske_language_length_2.to_i <= MAX_SKE_LENGTH

      errors.add(:ske_language_length_1, "The 2 courses must not add up to more than #{MAX_SKE_LENGTH} weeks")
      errors.add(:ske_language_length_2, "The 2 courses must not add up to more than #{MAX_SKE_LENGTH} weeks")
    end

    def ske_language_selected
      if Array(ske_language_required).compact_blank.empty?
        errors.add(:ske_language_required, :blank)
      end

      ske_languages.each do |language|
        errors.add(:ske_language_required, :inclusion) unless language.in?(SKE_LANGUAGES_WITH_NO_SKE_REQUIRED_INCLUDED)
      end
    end

    def ske_reasons_are_valid
      ske_reasons.each do |ske_reason|
        ske_reason.valid?
        ske_reason.errors.each do |error|
          field_name = "ske_reasons[#{ske_reason.language}][#{error.attribute}]"
          errors.add(field_name, "#{ske_reason.language.titleize}: #{error.full_message.downcase}")
        end
      end
    end

    def ske_language_length_1_presence
      if ske_language_length_1.blank?
        errors.add(:ske_language_length_1, :blank, subject: first_ske_language)
      end
    end

    def ske_language_length_2_presence
      if ske_language_length_2.blank?
        errors.add(:ske_language_length_2, :blank, subject: second_ske_language)
      end
    end

    def one_language?
      ske_languages.one?
    end

    def first_ske_language
      ske_languages.first
    end

    def second_ske_language
      ske_languages.second
    end

    def steps
      case decision.to_sym
      when :change_offer
        [INITIAL_STEP] + CHANGE_OFFER_STEPS + FINAL_STEPS
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
      assign_attributes(last_saved_state.merge(option))
      save_state!
    end

    def ske_conditions_are_valid
      return unless ske_required?

      if at_or_past(:ske_requirements) && language_course?
        validate_ske_conditions(:language)
        validate_language_count
      end

      if at_or_past(:ske_length)
        validate_ske_conditions(:length)
        validate_combined_ske_length if multiple_ske_conditions?
      end

      validate_ske_conditions(:reason) if at_or_past(:ske_reason)
    end

    def at_or_past(step)
      steps.index(step.to_sym) <= steps.index(current_step.to_sym)
    end

    def validate_ske_conditions(context)
      ske_conditions.each { |sc| sc.validate(context) }
    end

    def validate_combined_ske_length
      errors.add(:base, :ske_length_too_long) if ske_conditions.sum(&:length) > MAX_SKE_LENGTH
    end

    def validate_language_count
      if ske_conditions.length > MAX_SKE_LANGUAGES
        errors.add(:base, :ske_language_count)
      elsif ske_conditions.none? && Array(ske_required) != ['false']
        errors.add(:base, :ske_language_required)
      end
    end

    def multiple_ske_conditions?
      ske_conditions.length > 1
    end
  end
end
