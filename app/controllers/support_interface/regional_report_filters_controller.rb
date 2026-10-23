module SupportInterface
  class RegionalReportFiltersController < SupportInterfaceController
    before_action :authorize_support_user
    before_action :set_provider
    before_action :set_region

    def new
      @form = RegionalReportForm.new(region: @region)
    end

    def create
      @form = RegionalReportForm.new(expected_params)

      if @form.save
        redirect_to support_interface_provider_recruitment_report_path(region: @form.region)
      else
        render :new
      end
    end

  private

    def set_provider
      @provider ||= Provider.find(params.permit(:provider_id)[:provider_id])
    end

    def all_of_england
      ReportSharedEnums.all_of_england_key
    end

    def set_region
      @region = params[:region] || all_of_england
    end

    def expected_params
      params.expect(
        support_interface_regional_report_form: [:region],
      )
    end

    def authorize_support_user
      authorize(nil, :show?, policy_class: SupportInterface::ReportPolicy)
    end
  end
end
