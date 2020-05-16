module SupportInterface
  class FeatureAuditTrailComponentPreview < ViewComponent::Preview
    def pilot_open
      render SupportInterface::FeatureAuditTrailComponent.new(
        feature: Feature.find_by(name: 'pilot_open'),
      )
    end
  end
end
