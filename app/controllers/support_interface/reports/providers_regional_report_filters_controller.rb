module SupportInterface
  module Reports
    class ProvidersRegionalReportFiltersController < SupportInterface::RegionalReportFiltersController
      def create
        @form = RegionalReportForm.new(expected_params)

        if @form.save
          redirect_to support_interface_reports_provider_recruitment_report_path(
            provider_id: @provider.id,
            region: @form.region,
            recruitment_cycle_year: @recruitment_cycle_year,
          )
        else
          render :new
        end
      end
    end
  end
end
