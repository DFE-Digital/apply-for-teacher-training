module ProviderInterface
  class ApplicationChoiceInterviewsListComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_choice, :user_can_create_or_change_interviews

    def initialize(application_choice:, user_can_create_or_change_interviews:)
      @application_choice = application_choice
      @interviews = application_choice.interviews.kept.includes(:provider).order(:date_and_time)
      @user_can_create_or_change_interviews = user_can_create_or_change_interviews
    end

    def upcoming_interviews
      @interviews.upcoming
    end

    def past_interviews
      @interviews.past
    end
  end
end
