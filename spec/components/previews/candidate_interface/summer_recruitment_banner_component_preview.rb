module CandidateInterface
  class SummerRecruitmentBannerComponentPreview < ViewComponent::Preview
    def twenty_twenty_four
      application_form = ApplicationForm.new(recruitment_cycle_year: 2024, phase: 'apply_1')

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
