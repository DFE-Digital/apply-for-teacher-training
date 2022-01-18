module ProviderInterface
  class OfferWizard
    include Wizard
    include Wizard::PathHistory

    STEPS = { make_offer: %i[select_option conditions check],
              change_offer: %i[select_option providers courses study_modes locations conditions check] }.freeze
    MAX_FURTHER_CONDITIONS = OfferValidations::MAX_CONDITIONS_COUNT - OfferCondition::STANDARD_CONDITIONS.length

    attr_accessor :provider_id, :course_id, :course_option_id, :study_mode,
                  :standard_conditions, :further_condition_attrs, :decision,
                  :path_history,
                  :provider_user_id, :application_choice_id

    validates :decision, presence: true, on: %i[select_option]
    validates :course_option_id, presence: true, on: %i[locations save]
    validates :study_mode, presence: true, on: %i[study_modes save]
    validates :course_id, presence: true, on: %i[courses save]
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
      return unless index

      next_step = STEPS[decision.to_sym][index + 1]

      return save_and_go_to_next_step(next_step) if next_step.eql?(:providers) && available_providers.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:courses) && available_courses.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:study_modes) && available_study_modes.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:locations) && available_course_options.length == 1

      next_step
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

  private

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
      OfferedCourseOptionDetailsCheck.new(provider_id: provider_id,
                                          course_id: course_id,
                                          course_option_id: course_option_id,
                                          study_mode: study_mode).validate!
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
      query_service.available_courses(provider: provider)
    end

    def available_study_modes
      query_service.available_study_modes(course: course)
    end

    def available_course_options
      query_service.available_course_options(course: course, study_mode: study_mode)
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

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  end
end
