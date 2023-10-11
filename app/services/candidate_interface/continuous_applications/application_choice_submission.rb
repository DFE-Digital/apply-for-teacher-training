module CandidateInterface
  module ContinuousApplications
    class ApplicationChoiceSubmission
      include ActiveModel::Model
      attr_accessor :application_choice

      delegate :application_form, to: :application_choice
      validates :application_choice,
                applications_closed: true
    end
  end
end
