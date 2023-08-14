module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceSubmission
      include ActiveModel::Model
      attr_accessor :application_choice

      delegate :application_form, to: :application_choice
      validates :application_choice,
                cycle_verification: true,
                your_details_completion: true,
                submission_availability: true,
                open_for_applications: true,
                course_availability: true
    end
  end
end
