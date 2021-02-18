module CandidateInterface
  class ApplyAgainBannerComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_form

    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def all_withdrawn_copy
      'Your application has been withdrawn.' if all_applications_withdrawn?
    end

    def deadline_copy
      return nil unless show_deadline_copy?

      "The deadline when applying again is #{apply_2_deadline_date} for courses starting this academic year."
    end

    def render?
      !EndOfCycleTimetable.between_cycles_apply_2? &&
        application_form.recruitment_cycle_year == RecruitmentCycle.current_year
    end

    def start_path
      candidate_interface_start_apply_again_path
    end

  private

    def all_applications_withdrawn?
      application_form.application_choices.all?(&:cancelled?)
    end

    def show_deadline_copy?
      EndOfCycleTimetable.show_apply_2_deadline_banner? && FeatureFlag.active?(:deadline_notices)
    end

    def apply_2_deadline_date
      EndOfCycleTimetable.date(:apply_2_deadline).to_s(:govuk_date)
    end
  end
end
