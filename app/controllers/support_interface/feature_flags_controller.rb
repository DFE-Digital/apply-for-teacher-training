module SupportInterface
  class FeatureFlagsController < SupportInterfaceController
    def index; end

    def activate
      FeatureFlag.activate(params[:feature_name])
      flash[:success] = "#{params[:feature_name].humanize} activated"
      redirect_to support_interface_feature_flags_path
    end

    def deactivate
      FeatureFlag.deactivate(params[:feature_name])
      flash[:success] = "#{params[:feature_name].humanize} deactivated"
      redirect_to support_interface_feature_flags_path
    end
  end
end
