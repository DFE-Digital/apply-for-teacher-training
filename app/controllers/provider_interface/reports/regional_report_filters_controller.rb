module ProviderInterface
  module Reports
    class RegionalReportFiltersController < ProviderInterfaceController
      before_action :set_provider
      before_action :set_region, only: %i[new]

      def new
        @form = Shared::ProviderRegionalReportForm.initialize_from_report_filter(
          provider_id: @provider.id,
          provider_user_id: current_user.id,
        )
      end

      def create
        @form = Shared::ProviderRegionalReportForm.new(form_params)

        if @form.save
          flash[:success] = 'Comparison region updated'
          redirect_to provider_interface_reports_provider_recruitment_performance_report_path
        else
          render :new
        end
      end

    private

      def set_provider
        @provider ||= current_user.providers.find(
          params.permit(:provider_id)[:provider_id],
        )
      end

      def all_of_england
        Publications::RegionalRecruitmentPerformanceReport.all_of_england_key
      end

      def set_region
        @region = RegionalReportFilter.find_by(
          provider_id: @provider.id,
          provider_user_id: current_user.id,
        )&.region || all_of_england
      end

      def regional_report
        if @provider_report.present?
          @regional_report ||=
            Publications::RegionalRecruitmentPerformanceReport.where(
              cycle_week: @provider_report.cycle_week,
              region: @region,
            ).last
        end
      end

      def national_report
        if @provider_report.present?
          @national_report ||=
            Publications::NationalRecruitmentPerformanceReport.where(
              cycle_week: @provider_report.cycle_week,
            ).last
        end
      end

      def latest_report
        Publications::ProviderRecruitmentPerformanceReport
          .where(provider: @provider)
          .order(:recruitment_cycle_year, :cycle_week)
          .last
      end

      def provider_id
        params.permit(:provider_id)[:provider_id]
      end

      def form_params
        expected_params.merge(
          provider_id: @provider.id,
          provider_user_id: current_user.id,
        )
      end

      def expected_params
        params.expect(
          shared_provider_regional_report_form: [:region],
        )
      end
    end
  end
end
