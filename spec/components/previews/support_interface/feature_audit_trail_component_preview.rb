module SupportInterface
  class FeatureAuditTrailComponentPreview < ViewComponent::Preview
    def pilot_open
      render SupportInterface::FeatureAuditTrailComponent.new(
        feature: Feature.find_by(name: 'dfe_sign_in_fallback'),
      )
    end
  end
end
