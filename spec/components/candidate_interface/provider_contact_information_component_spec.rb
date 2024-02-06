require 'rails_helper'

RSpec.describe CandidateInterface::ProviderContactInformationComponent do
  let(:component) { described_class.new(provider:) }
  let(:provider) { build(:provider) }
  let(:result) { render_inline(component) }

  context 'when provider has phone and email' do
    it 'show provider contact information' do
      expect(result.text).to include('Contact training provider',
                                     "Call on #{provider.phone_number}",
                                     "email at #{provider.email_address}")
    end
  end

  context 'when provider has only phone' do
    let(:provider) do
      create(:provider, email_address: nil)
    end

    it 'show provider phone number' do
      expect(result.text).to include('Contact training provider',
                                     "Call on #{provider.phone_number}")
      expect(result.text).not_to include('email at')
    end
  end

  context 'when provider has only email' do
    let(:provider) do
      create(:provider, phone_number: nil)
    end

    it 'show provider contact information' do
      expect(result.text).to include('Contact training provider',
                                     "Email at #{provider.email_address}")
    end
  end

  context 'when provider has no contact information' do
    let(:provider) do
      create(:provider, email_address: nil, phone_number: nil)
    end

    it 'show provider contact information' do
      expect(result.text).to be_blank
    end
  end
end
