module CandidateInterface
  class CompleteSectionComponent < ViewComponent::Base
    validates :application_form, :path, :field_name, presence: true

    def initialize(application_form:, path:, field_name:)
      @application_form = application_form
      @path = path
      @field_name = field_name
    end
  end
end
