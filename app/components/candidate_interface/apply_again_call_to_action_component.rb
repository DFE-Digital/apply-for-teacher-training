module CandidateInterface
  class ApplyAgainCallToActionComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def title
      if offers_declined?
        "You’ve declined #{multiple_offers_declined? ? 'all of your offers' : 'your offer'}"
      elsif applications_withdrawn?
        "You’ve withdrawn your #{multiple_offers_withdrawn? ? 'applications' : 'application'}"
      else
        "Your #{multiple_applications? ? 'applications were' : 'application was'} unsuccessful"
      end
    end

    def render?
      application_form.ended_without_success? &&
        application_form.recruitment_cycle_year == RecruitmentCycle.current_year &&
        CycleTimetable.currently_mid_cycle?(application_form)
    end

  private

    def offers_declined?
      statuses.include?('declined')
    end

    def multiple_offers_declined?
      multiple_choices_with_status?('declined')
    end

    def applications_withdrawn?
      statuses.include?('withdrawn')
    end

    def multiple_offers_withdrawn?
      multiple_choices_with_status?('withdrawn')
    end

    def multiple_applications?
      statuses.count > 1
    end

    def multiple_choices_with_status?(status)
      statuses.select { |s| s == status }.count > 1
    end

    def statuses
      @statuses ||= application_form.application_choices.map(&:status)
    end
  end
end
