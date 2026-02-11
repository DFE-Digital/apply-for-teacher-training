module SupportInterface
  class ConfigureServiceBannerController < SupportInterfaceController
    def edit
      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new
      @interface = interface_param
    end

    def update
      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new(configure_service_banner_params)
      @interface = interface_param

      if @configure_service_banner_form.valid?
        redirect_to support_interface_feature_flags_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def configure_service_banner_params
      params.expect(support_interface_configure_service_banner_form: %i[banner_header banner_content])
    end

    def interface_param
      params.expect(:interface)
    end
  end
end
