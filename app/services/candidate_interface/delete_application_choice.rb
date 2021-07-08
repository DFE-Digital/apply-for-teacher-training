module CandidateInterface
  class DeleteApplicationChoice
    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def call
      application_form = @application_choice.application_form

      @application_choice.destroy!

      application_form.update!(course_choices_completed: nil) if application_form.application_choices.empty?
    end
  end
end
