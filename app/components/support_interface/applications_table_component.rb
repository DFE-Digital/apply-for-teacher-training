module SupportInterface
  class ApplicationsTableComponent < ApplicationComponent
    attr_reader :application_forms
    include ViewHelper

    def initialize(application_forms:, row_heading_level: 2)
      @application_forms = application_forms
      @row_heading_level = row_heading_level
    end
  end
end
