module SupportInterface
  class ConfigureServiceBannerController < SupportInterfaceController
    def new
      @interface = interface_param
      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new(interface: @interface)
    end

    def edit
      @interface = interface_param
      @banner = ServiceBanner.find(params[:id])

      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new(
        header: @banner.header,
        body: @banner.body,
        interface: @interface,
      )
    end

    def create
      @interface = interface_param
      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new(configure_service_banner_params.merge(interface: @interface))

      if @configure_service_banner_form.valid?
        @banner = @configure_service_banner_form.save
        redirect_to support_interface_preview_configure_service_banner_path(@banner, interface: @interface)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @interface = interface_param
      @banner = ServiceBanner.find(params[:id])
      @configure_service_banner_form = SupportInterface::ConfigureServiceBannerForm.new(configure_service_banner_params.merge(banner: @banner, interface: @interface))

      if @configure_service_banner_form.valid?
        @configure_service_banner_form.save
        redirect_to support_interface_preview_configure_service_banner_path(@banner, interface: @interface)
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def preview
      @interface = interface_param
      @banner = ServiceBanner.find(params[:id])
    end

  private

    def configure_service_banner_params
      params.expect(support_interface_configure_service_banner_form: %i[header body])
    end

    def interface_param
      params.expect(:interface)
    end
  end
end
