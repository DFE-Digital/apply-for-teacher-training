module CandidateInterface
  class ApplicationCompleteContentComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
      @dates = ApplicationDates.new(@application_form)
    end

    delegate :any_accepted_offer?,
             :all_provider_decisions_made?,
             :any_awaiting_provider_decision?,
             :all_choices_withdrawn?,
             :any_recruited?,
             :any_deferred?,
             :any_offers?,
             :all_applications_not_sent?, to: :application_form

    def decline_by_default_remaining_days
      distance_in_days = (@dates.decline_by_default_at.to_date - Date.current).to_i

      [0, distance_in_days].max
    end

    def decline_by_default_date
      @dates.decline_by_default_at.to_s(:govuk_date)
    end

    def choice_count
      application_form.application_choices.size
    end

    def respond_by_date
      dates = ApplicationDates.new(@application_form)
      dates.reject_by_default_at.to_s(:govuk_date).strip if dates.reject_by_default_at
    end

  private

    attr_reader :application_form
  end
end
