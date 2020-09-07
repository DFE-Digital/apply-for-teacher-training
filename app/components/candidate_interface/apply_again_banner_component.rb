module CandidateInterface
  class ApplyAgainBannerComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      !EndOfCycleTimetable.between_cycles_apply_2? &&
        @application_form.recruitment_cycle_year == RecruitmentCycle.current_year
    end

    def show_deadline_copy?
      EndOfCycleTimetable.show_apply_2_deadline_banner? && FeatureFlag.active?(:deadline_notices)
    end

    def start_path
      candidate_interface_start_apply_again_path
    end

    def apply_2_deadline_date
      EndOfCycleTimetable.date(:apply_2_deadline).to_s(:govuk_date)
    end

    def current_cycle_span
      "(#{RecruitmentCycle.current_year} - #{RecruitmentCycle.next_year})"
    end

    def next_cycle_span
      "(#{RecruitmentCycle.next_year} - #{RecruitmentCycle.next_year + 1})"
    end
  end
end
