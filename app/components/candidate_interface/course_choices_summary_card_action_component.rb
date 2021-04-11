module CandidateInterface
  class CourseChoicesSummaryCardActionComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :action, :application_choice

    def initialize(action:, application_choice:)
      @action = action
      @application_choice = application_choice
    end

    def respond_to_offer_detail
      if application_choice.application_form.all_provider_decisions_made?
        "You have #{pluralize(days_left_to_respond, 'day')} (until #{application_choice.decline_by_default_at.to_s(:govuk_date)}) to respond."
      else
        'You can wait to hear back from everyone before you respond.'
      end
    end

  private

    def decline_by_default_date
      application_choice.application_form.application_choices.offer.map(&:decline_by_default_at).min || Time.zone.now
    end

    def days_left_to_respond
      duration_in_days = (decline_by_default_date.to_date - Date.current).to_i
      [0, duration_in_days].max
    end
  end
end
