module CandidateInterface
  class DeleteApplicationChoice
    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def call
      application_form = @application_choice.application_form

      ActiveRecord::Base.transaction do
        @application_choice.published_invites.update_all(
          application_choice_id: nil,
          candidate_decision: 'not_responded',
        )

        @application_choice.destroy!
      end

      application_form.update!(course_choices_completed: nil) if application_form.application_choices.empty?
    end
  end
end
