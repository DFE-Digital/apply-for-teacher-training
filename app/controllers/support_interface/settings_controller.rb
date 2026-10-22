module SupportInterface
  class SettingsController < SupportInterfaceController
    def activate_feature_flag
      authorize nil, :edit?, policy_class: ::SupportInterface::FeatureFlagPolicy

      FeatureFlag.activate(params[:feature_name])

      flash[:success] = "Feature ‘#{feature_name}’ activated"
      redirect_to support_interface_feature_flags_path
    end

    def deactivate_feature_flag
      authorize nil, :edit?, policy_class: ::SupportInterface::FeatureFlagPolicy

      FeatureFlag.deactivate(params[:feature_name])

      flash[:success] = "Feature ‘#{feature_name}’ deactivated"
      redirect_to support_interface_feature_flags_path
    end

    def feature_flags
      authorize nil, :show?, policy_class: SupportInterface::FeatureFlagPolicy

      feature_names = FeatureFlag::FEATURES.map(&:first)
      @obsolete_features = Feature
                             .where.not(name: feature_names)
                             .order(:name)
                             .map(&:name)
    end

    def service_banners
      authorize nil, :show?, policy_class: SupportInterface::ServiceBannerPolicy
    end

  private

    def feature_name
      params.expect(:feature_name).humanize
    end
  end
end
