module SupportInterface
  class ProviderRecruitmentReportsController < SupportInterfaceController
    before_action :set_provider
    before_action :set_region, only: %i[show new]

    def show
      @provider_report = latest_report.present? ? Publications::ProviderRecruitmentPerformanceReportPresenter.new(latest_report) : nil
      @provider_data = @provider_report&.statistics

      all_of_england = Shared::RegionalReportForm::ALL_REGIONS
      @report_type = @region == all_of_england ? :NATIONAL : :REGIONAL
      @statistics = @region == all_of_england ? national_report&.statistics : regional_report&.statistics

      @disability_data = ProviderInterface::DiversityDataByProvider.new(
        provider: Provider.find(11),
        recruitment_cycle_year: 2026,
      ).disability_data
    end

    def new
      @form = Shared::RegionalReportForm.new(region: @region)
    end

    def create
      @form = Shared::RegionalReportForm.new(expected_params)

      if @form.save
        redirect_to support_interface_provider_recruitment_report_path(region: @form.region)
      else
        render :new
      end
    end

  private

    def set_provider
      @provider ||= Provider.find(provider_id)
    end

    def set_region
      @region = params[:region] || Shared::RegionalReportForm::ALL_REGIONS
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

    def expected_params
      params.expect(
        shared_regional_report_form: [:region],
      )
    end
  end
end
