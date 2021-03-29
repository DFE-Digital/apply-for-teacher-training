require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponents::RecruitedComponent do
  subject(:component) { described_class.new(application_choice: build_stubbed(:application_choice, :with_recruited), options: options) }

  let(:result) { render_inline(component) }
  let(:options) {}

  context 'when :provider_can_respond' do
    let(:options) { { provider_can_respond: true } }

    it 'displays the defer offer link' do
      expect(result.css('.govuk-body a').first.text).to eq('Defer offer')
      expect(result.css('.govuk-body a').count).to eq(1)
    end
  end

  context 'when :provider_can_respond is false' do
    let(:options) { { provider_can_respond: false } }

    it 'does not display any links' do
      expect(result.css('.govuk-body a')).to be_empty
    end
  end
end
