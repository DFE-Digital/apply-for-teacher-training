module ProviderInterface
  class OfferWizard
    include Wizard
    include Wizard::PathHistory

    SKE_LENGTH = 8.step(by: 4).take(6).freeze
    STEPS = {
      make_offer: %i[select_option ske_language_flow ske_standard_flow ske_reason ske_length conditions check],
      change_offer: %i[select_option providers courses study_modes locations conditions check],
    }.freeze
    MAX_FURTHER_CONDITIONS = OfferValidations::MAX_CONDITIONS_COUNT - OfferCondition::STANDARD_CONDITIONS.length
    MAX_SKE_LANGUAGES = 2

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode,
                  :standard_conditions, :further_condition_attrs, :decision,
                  :path_history,
                  :provider_user_id, :application_choice_id,
                  :ske_required, :ske_language_required, :ske_reason, :ske_language_reason_1,
                  :ske_language_reason_2, :ske_language_length_1, :ske_language_length_2, :ske_length

    validates :decision, presence: true, on: %i[select_option]
    validates :course_option_id, presence: true, on: %i[locations save]
    validates :study_mode, presence: true, on: %i[study_modes save]
    validates :course_id, presence: true, on: %i[courses save]
    validates :ske_required, presence: true, on: %i[ske_standard_flow]
    validates :ske_reason, presence: true, on: %i[ske_reason], unless: :ske_language_flow?
    validates :ske_language_reason_1, presence: true, on: %i[ske_reason], if: :ske_language_flow?
    validates :ske_language_reason_2, presence: true, on: %i[ske_reason], if: :ske_language_flow?
    validates :ske_length, presence: true, on: %i[ske_length], unless: :ske_language_flow?
    validates :ske_language_length_1, presence: true, on: %i[ske_length], if: :ske_language_flow?
    validates :ske_language_length_2, presence: true, on: %i[ske_length], if: :ske_language_flow?
    validate :ske_languages_selected, on: %i[ske_language_flow]
    validate :no_languages_selected, on: %i[ske_language_flow]
    validate :further_conditions_valid, on: %i[conditions]
    validate :max_conditions_length, on: %i[conditions]
    validate :course_option_details, if: :course_option_id, on: :save
    validate :ske_length_less_than_36_weeks, on: %i[ske_length]
    validate :ske_language_selected, on: %i[ske_language_flow]

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

    def next_step(step = current_step)
      index = STEPS[decision.to_sym].index(step.to_sym)

      if first_page_with_ske_feature_flag_disabled?(index)
        # Jump SKE flow if feature is disabled
        # get the index for the ske length (one less than the conditions page
        # which is after the ske flow)
        index = STEPS[decision.to_sym].index(:ske_length)
      end
      return unless index

      next_step = STEPS[decision.to_sym][index + 1]

      if FeatureFlag.active?(:provider_ske)
        next_page = find_next_step_for_ske
        next_step = next_page if next_page.present?
      end

      return save_and_go_to_next_step(next_step) if next_step.eql?(:providers) && available_providers.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:courses) && available_courses.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:study_modes) && available_study_modes.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:locations) && available_course_options.length == 1

      next_step
    end

    def no_ske_required?
      ActiveModel::Type::Boolean.new.cast(@ske_required).blank?
    end

    def no_languages_ske_required?
      ske_languages == ['no']
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

    def ske_language_flow?
      ske_language_required.present?
    end

    def ske_languages
      Array(ske_language_required).compact_blank
    end

  private

    def go_to_page(page)
      index = STEPS[decision.to_sym].index(page)
      STEPS[decision.to_sym][index]
    end

    def find_next_step_for_ske
      if current_step.to_sym == :select_option && course_subject_for_language_flow?
        go_to_page(:ske_language_flow)
      elsif (current_step.to_sym == :ske_language_flow && no_languages_ske_required?) || (current_step.to_sym == :ske_standard_flow && no_ske_required?)
        go_to_page(:conditions)
      elsif current_step.to_sym == :ske_language_flow
        go_to_page(:ske_reason)
      elsif current_step.to_sym == :select_option
        go_to_page(:ske_standard_flow)
      end
    end

    def self.standard_conditions_from(offer)
      return OfferCondition::STANDARD_CONDITIONS if offer.blank?

      conditions = offer.conditions_text
      conditions & OfferCondition::STANDARD_CONDITIONS
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

    def save_and_go_to_next_step(step)
      attrs = { provider_id: available_providers.first.id } if step.eql?(:providers)
      attrs = { course_id: available_courses.first.id } if step.eql?(:courses)
      attrs = { study_mode: available_study_modes.first } if step.eql?(:study_modes)
      attrs = { course_option_id: available_course_options.first.id } if step.eql?(:locations)

      assign_attributes(last_saved_state.merge(attrs))
      save_state!

      next_step(step)
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
      %w[state_store errors validation_context query_service wizard_path_history _further_condition_models]
    end

    def further_conditions_valid
      further_condition_models.map(&:valid?).all?

      further_condition_models.each do |model|
        model.errors.each do |error|
          field_name = "further_conditions[#{model.id}][#{error.attribute}]"
          create_method(field_name) { error.message }

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

    def create_method(name, &)
      self.class.send(:define_method, name, &)
    end

    def first_page_with_ske_feature_flag_disabled?(index)
      index.zero? && FeatureFlag.inactive?(:provider_ske) && decision.to_sym == :make_offer
    end

    def course_subject_for_language_flow?
      subject = course_option.course.subjects.first
      MinisterialReport::SUBJECT_CODE_MAPPINGS[subject&.code] == :modern_foreign_languages
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

    def ske_length_less_than_36_weeks
      return if ske_language_length_1.to_i + ske_language_length_2.to_i <= 36

      errors.add(:base, 'The 2 courses must not add up to more than 36 weeks')
    end

    def ske_language_selected
      if Array(ske_language_required).compact_blank.empty?
        errors.add(:ske_language_required, :blank)
      end
    end
  end
end
