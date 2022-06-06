require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationHeaderComponents::RejectionReasonRequiredComponent do
  describe 'rendered component' do
    let(:application_choice) { build_stubbed(:application_choice, status: 'rejected', rejected_by_default: true, rejected_at: rejected_at) }
    let(:rejected_at) { DateTime.new(2022, 2, 22, 23, 59, 59) }

    context 'when the provider user cannot give feedback' do
      it 'displays text about RBD' do
        result = render_inline(described_class.new(application_choice: application_choice, provider_can_respond: false))
        expect(result.css('.govuk-body').text.strip).to eq('This application was automatically rejected on 22 February 2022. Feedback has not been sent to the candidate.')
      end
    end

    context 'when the provder user can give feedback' do
      it 'displays text about RBD' do
        result = render_inline(described_class.new(application_choice: application_choice, provider_can_respond: true))
        expect(result.css('h2').text.strip).to eq('Give feedback')
        expect(result.css('.govuk-body').text.strip).to eq('You did not make a decision about the application within  working days. Tell the candidate why their application was unsuccessful.')
        expect(result.css('.govuk-button').text.strip).to eq('Give feedback')
      end
    end
  end
end
