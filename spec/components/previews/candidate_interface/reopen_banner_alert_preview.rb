module CandidateInterface
  class ReopenBannerAlertPreview < ViewComponent::Preview
    def reopen_banner_component
      application_form = FactoryBot.build(:application_form, recruitment_cycle_year: RecruitmentCycleTimetable.previous_year)
      render CandidateInterface::ReopenBannerComponentPreviewComponent.new(
        flash_empty: true,
        application_form:,
      )
    end
  end

  class CandidateInterface::ReopenBannerComponentPreviewComponent < CandidateInterface::ReopenBannerComponent
    def render?
      true
    end
  end
end
