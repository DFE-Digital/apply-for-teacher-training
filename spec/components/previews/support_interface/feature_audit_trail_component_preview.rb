module SupportInterface
  class FeatureAuditTrailComponentPreview < ViewComponent::Preview
    def default
      render SupportInterface::FeatureAuditTrailComponent.new(
        feature: Feature.all.sample,
      )
    end
  end
end
