module SupportInterface
  class RegionalReportFiltersController < SupportInterfaceController
    before_action :set_provider
    before_action :set_region

    def new
      @form = RegionalReportForm.new(region: @region)
      @backlink = if params[:return_to] == 'reports' && params[:recruitment_cycle_year].present?
                    support_interface_reports_recruitment_performance_report_path(
                      region: @region,
                      recruitment_cycle_year: params[:recruitment_cycle_year],
                    )
                  else
                    support_interface_provider_recruitment_report_path(region: @region)
                  end
    end

    def create
      @form = RegionalReportForm.new(expected_params)

      if @form.save
        if reports_page_params[:return_to] == 'reports'
          redirect_to support_interface_reports_recruitment_performance_report_path(
            region: @form.region,
            recruitment_cycle_year: reports_page_params[:recruitment_cycle_year],
          )
        else
          redirect_to support_interface_provider_recruitment_report_path(region: @form.region)
        end
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

    def reports_page_params
      params.expect(
        support_interface_regional_report_form: %i[
          region
          return_to
          provider_id
          recruitment_cycle_year
        ],
      )
    end
  end
end
