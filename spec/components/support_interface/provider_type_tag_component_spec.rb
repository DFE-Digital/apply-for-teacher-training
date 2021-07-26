require 'rails_helper'

RSpec.describe SupportInterface::ProviderTypeTagComponent do
  let(:provider) { build_stubbed(:provider, provider_type: provider_type) }

  subject!(:render) { render_inline(described_class.new(provider: provider)) }

  context 'when provider type is nil' do
    let(:provider_type) { nil }

    it 'does not render the component' do
      expect(render.text).to be_empty
    end
  end

  context 'when provider type is lead_school' do
    let(:provider_type) { :lead_school }

    it 'renders the a green tag with the correct text' do
      expect(page).to have_css('.govuk-tag--green', text: 'School Direct')
    end
  end

  context 'when provider type is scitt' do
    let(:provider_type) { :scitt }

    it 'renders the a yellow tag with the correct text' do
      expect(page).to have_css('.govuk-tag--yellow', text: 'SCITT')
    end
  end

  context 'when provider type is university' do
    let(:provider_type) { :university }

    it 'renders the a blue tag with the correct text' do
      expect(page).to have_css('.govuk-tag--blue', text: 'HEI')
    end
  end
end
