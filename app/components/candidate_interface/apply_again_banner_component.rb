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

    def render?
      !EndOfCycleTimetable.between_cycles_apply_2?
    end

    def start_path
      if EndOfCycleTimetable.current_cycle?(@application_form)
        candidate_interface_start_apply_again_path
      else
        candidate_interface_start_carry_over_path
      end
    end
  end
end
