module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceSubmission
      include ActiveModel::Model
      attr_accessor :application_choice

      delegate :application_form, to: :application_choice
      validates :application_choice,
                applications_closed: true,
                course_unavailable: { if: :validate_choice? },
                incomplete_details: { if: :validate_choice? }

    private

      def validate_choice?
        errors.exclude?(:application_choice)
      end
    end
  end
end
