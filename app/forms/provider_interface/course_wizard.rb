module ProviderInterface
  class CourseWizard
    include Wizard
    include Wizard::PathHistory

    STEPS = %i[select_option providers courses study_modes locations check].freeze

    attr_accessor :path_history, :provider_id, :decision, :provider_user, :application_choice_id

    def next_step(step = current_step)
      index = STEPS.index(step.to_sym)
      return unless index

      next_step = STEPS[index + 1]

      return save_and_go_to_next_step(next_step) if next_step.eql?(:providers) && available_providers.length == 1

      next_step
    end

  private

    def application_choice
      ApplicationChoice.find(application_choice_id)
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: provider_user,
        current_course: application_choice.current_course,
      )
    end

    def available_providers
      query_service.available_providers
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
  end
end
