module ProviderInterface
  class RejectByDefaultFeedbackComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :introduction, :rejection_reason

    def initialize(application_choice:, introduction: nil, rejection_reason: nil)
      @application_choice = application_choice
      @introduction = introduction
      @rejection_reason = rejection_reason
      @rejection_reason ||= application_choice.rejection_reason
    end
  end
end
