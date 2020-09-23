module SupportInterface
  class ApplicationsTableComponent < ViewComponent::Base
    attr_reader :application_forms
    include ViewHelper

    def initialize(application_forms:)
      @application_forms = application_forms
    end
  end
end
