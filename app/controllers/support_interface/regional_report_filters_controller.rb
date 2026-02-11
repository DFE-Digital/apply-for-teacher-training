module SupportInterface
  class RegionalReportFiltersController < SupportInterfaceController
    before_action :set_provider
    before_action :set_region

    def new
      @form = Shared::SupportRegionalReportForm.new(region: @region)
    end

    def create
      @form = Shared::SupportRegionalReportForm.new(expected_params)

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
      Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
    end

    def set_region
      @region = params[:region] || all_of_england
    end

    def expected_params
      params.expect(
        shared_support_regional_report_form: [:region],
      )
    end
  end
end
