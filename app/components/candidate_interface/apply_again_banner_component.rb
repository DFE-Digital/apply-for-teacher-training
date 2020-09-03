module CandidateInterface
  class ApplyAgainBannerComponent < ViewComponent::Base
    include ViewHelper
    validates :application_form, presence: true

    def initialize(application_form:)
      @application_form = application_form
    end

    def show_deadline_copy?
      EndOfCycleTimetable.show_apply_2_deadline_banner? && FeatureFlag.active?(:deadline_notices)
    end

    def start_path
      if EndOfCycleTimetable.current_cycle?(@application_form) &&
          !EndOfCycleTimetable.between_cycles_apply_2?
        candidate_interface_start_apply_again_path
      else
        candidate_interface_start_carry_over_path
      end
    end

    def reopen_date
      EndOfCycleTimetable.date(:apply_reopens).to_s(:govuk_date)
    end

    def find_reopen_date
      EndOfCycleTimetable.date(:find_reopens).to_s(:govuk_date)
    end
  end
end
