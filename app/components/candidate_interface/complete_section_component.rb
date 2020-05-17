module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    validates :application_form, :path, :request_method, :field_name, presence: true

    def initialize(application_form:, path:, request_method:, field_name:)
      @application_form = application_form
      @path = path
      @request_method = request_method
      @field_name = field_name
    end
  end
end
