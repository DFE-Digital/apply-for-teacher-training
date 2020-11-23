module ProviderInterface
  class ReasonsForRejectionComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice, :editable, :reasons_for_rejection

    def initialize(application_choice:, reasons_for_rejection:, editable: false)
      @application_choice = application_choice
      @reasons_for_rejection = reasons_for_rejection
      @editable = editable
    end

    def editable?
      editable
    end

    def subheading_tag_name
      editable? ? :h2 : :h3
    end
  end
end
