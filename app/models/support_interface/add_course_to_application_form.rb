module SupportInterface
  class AddCourseToApplicationForm
    include ActiveModel::Model
    attr_accessor :course_option_id, :application_form

    validate :application_form_in_correct_state
    validate :course_option_exists

    def save
      return unless valid?

      application_choice = ApplicationChoice.create!(
        application_form: application_form,
        course_option: course_option,
        status: 'unsubmitted',
      )

      SubmitApplicationChoice.new(
        application_choice,
        send_to_provider_immediately: awaiting_provider_decision?,
      ).call
    end

  private

    def course_option
      @course_option ||= CourseOption.find(course_option_id)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    def course_option_exists
      return if course_option

      errors[:base] << "There's no course option with ID #{course_option_id}"
    end

    def awaiting_references?
      application_form.application_choices.any?(&:awaiting_references?)
    end

    def awaiting_provider_decision?
      application_form.application_choices.any?(&:awaiting_provider_decision?)
    end

    # For simplicity we only support adding applications to forms that are in
    # "Awaiting references" or "Awaiting provider decision" state, because we
    # need to add the choices in the same state as other applications.
    def application_form_in_correct_state
      return if awaiting_references? || awaiting_provider_decision?

      errors[:base] << 'You can only add a course to an application that has at least 1 other application choice in the "awaiting references" or "awaiting_provider_decision" state.'
    end
  end
end
