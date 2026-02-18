module SupportInterface
  class ShowServiceBannerController < SupportInterfaceController
    def show
      @banner = ServiceBanner.find(params[:id])
    end

    def edit
      @show_service_banner_form = SupportInterface::ShowServiceBannerForm.new
      @interface = interface_param
    end

    def update
      @show_service_banner_form = SupportInterface::ShowServiceBannerForm.new(show_service_banner_params)
      @interface = interface_param

      if @show_service_banner_form.valid?
        if @show_service_banner_form.show_service_banner?
          redirect_to support_interface_new_configure_service_banner_path(interface: @interface)
        else
          live_banner&.update(status: 'used')
          redirect_to support_interface_service_banners_path
          flash[:success] = I18n.t('support_interface.show_service_banner.update.success', interface: @interface.humanize.titleize)
        end
      else
        @interface = interface_param
        render :edit, status: :unprocessable_entity
      end
    end

  private

    def live_banner
      ServiceBanner.where(interface: @interface, status: 'published').order(created_at: :desc).first
    end

    def show_service_banner_params
      params
      .fetch(:support_interface_show_service_banner_form, {})
      .permit(:show_service_banner)
    end

    def interface_param
      params.expect(:interface)
    end
  end
end
