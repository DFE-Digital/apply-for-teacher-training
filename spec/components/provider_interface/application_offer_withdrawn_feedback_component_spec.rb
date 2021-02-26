require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationOfferWithdrawnFeedbackComponent do
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:render) { render_inline described_class.new(application_choice: application_choice) }

  context 'when the application is not in the offer_withdrawn state' do
    it 'does not render' do
      expect(render.to_html).to be_blank
    end
  end

  context 'when the application is in the offer_withdrawn state' do
    let(:application_choice) { create(:application_choice, :with_withdrawn_offer) }

    it 'renders the date of offer withdrawal' do
      expect(render.text).to include('The offer was withdrawn on 31 October 2021')
    end

    it 'renders the reasons for offer withdrawal' do
      expect(render.css('.govuk-body').text).to include('The following feedback was sent to the candidate')
      expect(render.css('.govuk-inset-text').text).to include('There has been a mistake')
    end
  end
end
