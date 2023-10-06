require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::RespondComponent do
  describe 'rendered component' do
    context 'when the provider user can make a decision' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision) }

      it 'renders Make decision content' do
        result = render_inline(described_class.new(application_choice:, provider_can_respond: true))

        expect(result.css('h2').text.strip).to eq('Make a decision')
        expect(result.css('.govuk-body').text.strip).to eq(
          'This application was received today. You should try and respond to the candidate within 30 days.',
        )
        expect(result.css('.govuk-button').text.strip).to eq('Make decision')
      end
    end

    context 'when the provider user can set up interviews' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision) }

      it 'renders Set up interview content' do
        result = render_inline(described_class.new(application_choice:, provider_can_set_up_interviews: true))

        expect(result.css('h2').text.strip).to eq('Set up an interview')
        expect(result.css('.govuk-body').text.strip).to eq(
          'This application was received today. You should try and respond to the candidate within 30 days.',
        )
        expect(result.css('.govuk-button').text.strip).to eq('Set up interview')
      end
    end

    context 'when the provider user can make a decision and set up an interview' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision) }

      it 'renders Make decision content' do
        result = render_inline(
          described_class.new(
            application_choice:,
            provider_can_respond: true,
            provider_can_set_up_interviews: true,
          ),
        )

        expect(result.css('h2').text.strip).to eq('Set up an interview or make a decision')
        expect(result.css('.govuk-body').text.strip).to eq(
          'This application was received today. You should try and respond to the candidate within 30 days.',
        )
        expect(result.css('.govuk-button').first.text.strip).to eq('Set up interview')
        expect(result.css('.govuk-button').last.text.strip).to eq('Make decision')
      end
    end
  end
end
