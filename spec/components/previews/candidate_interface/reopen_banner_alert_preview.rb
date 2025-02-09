module CandidateInterface
  class ReopenBannerAlertPreview < ViewComponent::Preview
    def reopen_banner_component
      render CandidateInterface::ReopenBannerComponentPreviewComponent.new(
        flash_empty: true,
        current_timetable: RecruitmentCycleTimetable.current_timetable,
      )
    end
  end

  class CandidateInterface::ReopenBannerComponentPreviewComponent < CandidateInterface::ReopenBannerComponent
    def render?
      true
    end
  end
end
