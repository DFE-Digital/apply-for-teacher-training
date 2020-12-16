module VendorAPI
  class RejectionReasonPresenter
    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end

    def present
      if application_choice.structured_rejection_reasons.present?
        rejection_reasons
      else
        application_choice.rejection_reason
      end
    end

  private

    def rejection_reasons
      reasons = RejectedApplicationChoicePresenter.new(application_choice).rejection_reasons
      reasons.map { |k, v| %(#{k}:\n#{Array(v).join("\n")}) }.join("\n\n")
    end
  end
end
