module SupportInterface
  class RegionalReportFiltersController < SupportInterfaceController
    before_action :set_provider
    before_action :set_recruitment_cycle_year

    def new
      @form = RegionalReportForm.new(region: @region)
      @backlink = if params[:return_to] == 'reports'
                    support_interface_reports_provider_recruitment_report_path(
                      provider_id: @provider.id,
                      region: params[:region] || all_of_england,
                      recruitment_cycle_year: @recruitment_cycle_year,
                    )
                  else
                    support_interface_provider_recruitment_report_path(
                      @provider,
                      region: params[:region] || all_of_england,
                      recruitment_cycle_year: @recruitment_cycle_year,
                    )
                  end
    end

    def create
      @form = RegionalReportForm.new(expected_params)

      if @form.save
        if params[:support_interface_regional_report_form][:return_to] == 'reports'
          redirect_to support_interface_reports_provider_recruitment_report_path(
            provider_id: @provider.id,
            region: @form.region,
            recruitment_cycle_year: @recruitment_cycle_year,
          )
        else
          redirect_to support_interface_provider_recruitment_report_path(
            @provider,
            region: @form.region,
            recruitment_cycle_year: @recruitment_cycle_year,
          )
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

    def expected_params
      params.expect(
        support_interface_regional_report_form: %i[region recruitment_cycle_year],
      )
    end

    def set_recruitment_cycle_year
      @recruitment_cycle_year ||= params.permit(:recruitment_cycle_year)[:recruitment_cycle_year] ||
                                  expected_params[:recruitment_cycle_year]
    end

    def return_to
      params[:support_interface_regional_report_form][:return_to]
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
