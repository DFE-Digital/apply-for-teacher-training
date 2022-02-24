module ProviderInterface
  class CourseWizard
    include Wizard
    include Wizard::PathHistory

    STEPS = %i[select_option providers courses study_modes locations check].freeze

    attr_accessor :path_history, :provider_id, :decision, :application_choice_id,
                  :course_option_id, :course_id, :provider_user_id, :study_mode

    def self.build_from_application_choice(state_store, application_choice, options = {})
      course_option = application_choice.current_course_option

      attrs = {
        application_choice_id: application_choice.id,
        course_id: course_option.course.id,
        course_option_id: course_option.id,
        provider_id: course_option.provider.id,
      }.merge(options)

      new(state_store, attrs)
    end

    def next_step(step = current_step)
      index = STEPS.index(step.to_sym)
      return unless index

      next_step = STEPS[index + 1]

      return save_and_go_to_next_step(next_step) if next_step.eql?(:providers) && available_providers.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:courses) && available_courses.length == 1
      return save_and_go_to_next_step(next_step) if next_step.eql?(:study_modes) && available_study_modes.length == 1

      next_step
    end

  private

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

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: provider_user,
        current_course: application_choice.current_course,
      )
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
