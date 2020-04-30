module Integrations
  class FeatureFlagsController < IntegrationsController
    def index
      feature_flags = FeatureFlag::FEATURES.index_with do |feature_name|
        {
          name: feature_name.humanize,
          active: FeatureFlag.active?(feature_name),
        }
      end

      response = {
        hosting_environment: HostingEnvironment.environment_name,
        sandbox_mode: HostingEnvironment.sandbox_mode?,
        feature_flags: feature_flags,
      }

      render json: response
    end
  end
end
