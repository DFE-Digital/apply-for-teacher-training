module SupportInterface
  class ShowServiceBannerController < SupportInterfaceController
    def edit
      @show_service_banner_form = SupportInterface::ShowServiceBannerForm.new
      @interface = interface_param
    end

    def update
      @show_service_banner_form = SupportInterface::ShowServiceBannerForm.new(show_service_banner_params)
      @interface = interface_param

      if @show_service_banner_form.valid?
        if @show_service_banner_form.show_service_banner?
          redirect_to support_interface_edit_configure_service_banner_path(interface: @interface)
        else
          redirect_to support_interface_service_banners_path
        end
      else
        @interface = interface_param
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def show_service_banner_params
      params.expect(support_interface_show_service_banner_form: [:show_service_banner])
    end

    def interface_param
      params.expect(:interface)
    end
  end
end
