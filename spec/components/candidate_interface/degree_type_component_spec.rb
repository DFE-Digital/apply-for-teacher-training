require 'rails_helper'

RSpec.describe CandidateInterface::DegreeTypeComponent, type: :component do
  describe 'uk degree' do
    let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Bachelor degree' } }
    let(:wizard) { CandidateInterface::DegreeWizard.new(store, degree_params) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }

    before { allow(store).to receive(:read) }

    subject(:component) { described_class.new(type: wizard) }

    describe '#find_degree_type_options' do
      it 'returns array of record objects of bachelor degrees' do
        expect(component.find_degree_type_options).to include({ name: 'Bachelor of Arts', abbreviation: 'BA' })
        expect(component.find_degree_type_options).not_to include({ name: 'Master of Arts', abbreviation: 'MA' })
      end
    end

    describe '#dynamic_types' do
      context 'degree type with degree suffix' do
        it 'returns the degree level' do
          expect(component.dynamic_types).to eq('bachelor degree')
          expect(component.dynamic_types).not_to eq('master’s degree')
        end
      end

      context 'doctorate (phd) degree type' do
        let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'Doctorate (PhD)' } }

        it 'returns the degree level' do
          expect(component.dynamic_types).to eq('doctorate')
          expect(component.dynamic_types).not_to eq('master’s degree')
        end
      end
    end

    describe '.degree_types' do
      it 'returns a hash of degree types' do
        expect(described_class.degree_types).to eq(
          {
            'Foundation degree' => [{
              name: 'Foundation of Arts',
              abbreviation: 'FdA',
            }, {
              name: 'Foundation Degree of Education',
              abbreviation: 'FDEd',
            }, {
              name: 'Foundation of Sciences',
              abbreviation: 'FdSs',
            }],
            'Bachelor degree' => [{
              name: 'Bachelor of Arts',
              abbreviation: 'BA',
            }, {
              name: 'Bachelor of Engineering',
              abbreviation: 'BEng',
            }, {
              name: 'Bachelor of Science',
              abbreviation: 'BSc',
            }, {
              name: 'Bachelor of Education',
              abbreviation: 'BEd',
            }],
            'Master’s degree' => [{
              name: 'Master of Arts',
              abbreviation: 'MA',
            }, {
              name: 'Master of Science',
              abbreviation: 'MSc',
            }, {
              name: 'Master of Education',
              abbreviation: 'MEd',
            }, {
              name: 'Master of Engineering',
              abbreviation: 'MEng',
            }],
            'Doctorate (PhD)' => [{
              name: 'Doctor of Philosophy',
              abbreviation: 'DPhil',
            }, {
              name: 'Doctor of Education',
              abbreviation: 'EdD',
            }],
          },
        )
      end
    end

    describe '#name_and_abbr' do
      let(:degree) { { name: 'Doctor of Philosophy', abbreviation: 'DPhil' } }

      it 'renders a correctly formatted degree type' do
        expect(component.name_and_abbr(degree)).to eq('Doctor of Philosophy (DPhil)')
      end
    end

    describe '#choose_degree_types' do
      %i[bachelor master doctor foundation].each do |level|
        it 'returns autocomplete choices scoped to the degree level' do
          expect(component.choose_degree_types(level).find { |type| type }).to include level.to_s.upcase_first.to_s
        end
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
      expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text)).to include(*component.find_degree_type_options.collect { |degree| component.name_and_abbr(degree) })
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
