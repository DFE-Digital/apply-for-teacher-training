module CandidateInterface
  class CompletedApplicationForm
    include ActiveModel::Model

    attr_accessor :application_form
    validates :application_form, your_details_completion: true
  end
end
