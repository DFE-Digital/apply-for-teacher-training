require 'rails_helper'

RSpec.describe CandidateInterface::Covid19DashboardBannerComponent do
  context 'when the COVID-19 feature flag is on' do
    before { FeatureFlag.activate('covid_19') }

    context 'and the application form is not enrolled' do
      it 'renders the banner' do
        application_form = build_stubbed(:application_form)
        allow(application_form).to receive(:any_enrolled?).and_return(false)

        result = render_inline(CandidateInterface::Covid19DashboardBannerComponent.new(application_form: application_form))

        expect(result.text).to include('Coronavirus (COVID-19)')
      end
    end

    context 'and the application form is enrolled' do
      it 'does not render the banner' do
        application_form = build_stubbed(:application_form)
        allow(application_form).to receive(:any_enrolled?).and_return(true)

        result = render_inline(CandidateInterface::Covid19DashboardBannerComponent.new(application_form: application_form))

        expect(result.text).to eq('')
      end
    end
  end

  context 'when the COVID-19 feature flag is off' do
    it 'does not render the banner' do
      FeatureFlag.deactivate('covid_19')
      application_form = build_stubbed(:application_form)

      result = render_inline(CandidateInterface::Covid19DashboardBannerComponent.new(application_form: application_form))

      expect(result.text).to eq('')
    end
  end
end
