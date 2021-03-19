module CandidateInterface
  class ApplicationDashboardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def title
      t('page_titles.application_dashboard')
    end
  end
end
