module CandidateInterface
  class ReopenBannerAlertPreview < ViewComponent::Preview
    def reopen_banner_component
      render CandidateInterface::ReopenBannerComponentPreviewComponent.new(
        flash_empty: true,
      )
    end
  end

  class CandidateInterface::ReopenBannerComponentPreviewComponent < CandidateInterface::ReopenBannerComponent
    def render?
      true
    end
  end
end
