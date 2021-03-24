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
