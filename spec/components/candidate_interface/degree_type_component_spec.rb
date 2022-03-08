require 'rails_helper'

RSpec.describe CandidateInterface::DegreeTypeComponent, type: :component do
  describe 'uk degree' do
    let(:degree_params) { { uk_or_non_uk: 'uk', level: 'Bachelor degree' } }
    let(:wizard) { CandidateInterface::DegreeWizard.new(store, degree_params) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }

    before { allow(store).to receive(:read) }

    subject(:component) { described_class.new(type: wizard) }

    describe '#find_degree_type_options' do
      it 'returns types of bachelor degree' do
        expect(component.find_degree_type_options).to include('Bachelor of Arts (BA)')
        expect(component.find_degree_type_options).not_to include('Master of Arts (MA)')
      end
    end

    describe '#degree_level' do
      it 'returns the degree level' do
        expect(component.degree_level).to eq('Bachelor')
        expect(component.degree_level).not_to eq('Master’s')
      end
    end

    describe '#map_hint' do
      it 'renders the correct hint' do
        expect(component.map_hint).to eq('Bachelor of Engineering (BEng)')
        expect(component.map_hint).not_to eq('Master of Engineering (MEng)')
      end
    end

    it 'renders radio button options' do
      result = render_inline(component)

      expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(5)
      expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text)).to include(*component.find_degree_type_options)
    end
  end

  describe 'non_uk degree' do
    let(:degree_params) { { uk_or_non_uk: 'non_uk' } }
    let(:wizard) { CandidateInterface::DegreeWizard.new(store, degree_params) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }

    before { allow(store).to receive(:read) }

    subject(:component) { described_class.new(type: wizard) }

    it 'renders text field with correct hint' do
      result = render_inline(component)

      expect(result.css('.govuk-fieldset__legend').text).to eq 'What type of degree is it?'
      expect(result.css('.govuk-hint').text).to eq t('application_form.degree.international_qualification_type.hint_text')
    end
  end
end
