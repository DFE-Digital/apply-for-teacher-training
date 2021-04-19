module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    attr_reader :completion_form, :path, :request_method, :field_name, :summary

    def initialize(completion_form:, path:, request_method:, field_name:, summary:)
      @completion_form = completion_form
      @path = path
      @request_method = request_method
      @field_name = field_name
      @summary = summary
    end
  end
end
