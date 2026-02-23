require 'rails_helper'

RSpec.describe ProviderInterface::Reports::RecruitmentPerformanceReportsController do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_provider) }
  let(:provider) { provider_user.providers.first }
  let(:provider_report) do
    create(:provider_recruitment_performance_report, provider:, recruitment_cycle_year: 2025)
  end
  let(:regional_report) do
    create(
      :regional_recruitment_performance_report,
      cycle_week: provider_report.cycle_week,
      recruitment_cycle_year: provider_report.recruitment_cycle_year,
    )
  end
  let(:national_report) do
    create(
      :national_recruitment_performance_report,
      cycle_week: provider_report.cycle_week,
      recruitment_cycle_year: provider_report.recruitment_cycle_year,
    )
  end

  before do
    provider_report
    regional_report
    national_report

    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'GET show' do
    it 'returns 200' do
      get provider_interface_reports_provider_recruitment_performance_report_path(provider_id: provider.id)

      expect(response).to have_http_status :ok
      expect(response.content_type).to eq('text/html; charset=utf-8')
    end

    context 'when format is ZIP' do
      it 'returns 200' do
        get provider_interface_reports_provider_recruitment_performance_report_path(
          provider_id: provider.id,
          format: :zip,
        )

        expect(response).to have_http_status :ok
        expect(response.content_type).to eq('application/zip')
      end

      context 'when no report exists' do
        let(:provider_report) { nil }
        let(:regional_report) { nil }
        let(:national_report) { nil }

        it 'returns 404' do
          get provider_interface_reports_provider_recruitment_performance_report_path(
            provider_id: provider.id,
            format: :zip,
          )

          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
