module SupportInterface
  class FeatureToggleComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :feature_name

    def initialize(feature_name:)
      @feature_name = feature_name
    end

    def toggle_label
      FeatureFlag.active?(feature_name) ? 'Deactivate' : 'Activate'
    end

    def toggle_link
      FeatureFlag.active?(feature_name) ? support_interface_deactivate_feature_flag_path(feature_name) : support_interface_activate_feature_flag_path(feature_name)
    end

    def toggle_aria_label
      "#{toggle_label} ‘#{feature_name.humanize}’ feature"
    end
  end
end
