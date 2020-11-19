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

    def feedback_heading
      if reasons_for_rejection.interested_in_future_applications_y_n == 'Yes'
        'The provider would be interested in future applications from you'
      else
        'Training provider feedback'
      end
    end
  end
end
