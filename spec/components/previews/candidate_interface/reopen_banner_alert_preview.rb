module CandidateInterface
  class ReopenBannerAlertPreview < ViewComponent::Preview
    def twenty_twenty_four
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
