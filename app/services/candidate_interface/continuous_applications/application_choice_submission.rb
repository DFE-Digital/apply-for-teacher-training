module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceSubmission
      include ActiveModel::Model
      attr_accessor :application_choice

      delegate :application_form, to: :application_choice
      validates :application_choice,
                applications_closed: true,
                course_unavailable: { if: :validate_choice? },
                incomplete_details: { if: :validate_choice? },
                incomplete_primary_course_details: { if: :validate_choice? },
                incomplete_including_primary_course_details: { if: :validate_choice? },
                already_submitted: { if: :validate_choice? },
                can_add_more_choices: true

    private

      def validate_choice?
        errors.exclude?(:application_choice)
      end
    end
  end
end
