module CandidateInterface
  class SummerRecruitmentBannerComponentPreview < ViewComponent::Preview
    def deadline_approaching_banner
      application_form = ApplicationForm.new(
        recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      )

      render CandidateInterface::SummerRecruitmentBannerComponent.new(
        application_form:,
        flash_empty: true,
      )
    end
  end

  class CandidateInterface::SummerRecruitmentBannerComponent < CandidateInterface::DeadlineBannerComponent
    def render?
      true
    end
  end
end
