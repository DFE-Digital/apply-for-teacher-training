require 'rails_helper'

RSpec.describe 'Support interface - Provider recruitment report' do
  include DfESignInHelpers

  let(:support_user) do
    create(
      :support_user,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
    )
  end
  let(:provider) { create(:provider) }
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

    support_user_exists_dsi(dfe_sign_in_uid: support_user.dfe_sign_in_uid)
    get auth_dfe_support_callback_path
  end

  describe 'GET show' do
    it 'returns 200' do
      get support_interface_provider_recruitment_report_path(provider_id: provider.id)

      expect(response).to have_http_status :ok
      expect(response.content_type).to eq('text/html; charset=utf-8')
    end

    context 'when format is ZIP' do
      it 'returns 200' do
        get support_interface_provider_recruitment_report_path(
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
          get support_interface_provider_recruitment_report_path(
            provider_id: provider.id,
            format: :zip,
          )

          expect(response).to have_http_status :not_found
        end
      end
    end
  end
end
