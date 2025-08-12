require 'rails_helper'

RSpec.describe CandidateInterface::DegreeTypeComponent, type: :component do
  describe 'uk degree' do
    let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: 'bachelor' } }
    let(:wizard) { CandidateInterface::Degrees::TypeForm.new(store, degree_params) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }

    before { allow(store).to receive(:read) }

    subject(:component) { described_class.new(model: wizard) }

    describe '#find_degree_type_options' do
      it 'returns array of record objects of bachelors degrees' do
        expect(component.find_degree_type_options).to include({ name: 'Bachelor of Arts', abbreviation: 'BA' })
        expect(component.find_degree_type_options).not_to include({ name: 'Master of Arts', abbreviation: 'MA' })
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
            'Bachelor’s degree' => [{
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
              abbreviation: 'PhD',
            }, {
              name: 'Doctor of Philosophy (DPhil)',
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
          expect(component.choose_degree_types(level).map(&:name)).to include(/#{level.to_s.upcase_first}/)
        end
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
    let(:wizard) { CandidateInterface::Degrees::BaseForm.new(store, degree_params) }
    let(:store) { instance_double(WizardStateStores::RedisStore) }

    before { allow(store).to receive(:read) }

    subject(:component) { described_class.new(model: wizard) }

    it 'renders text field with correct hint' do
      result = render_inline(component)

      expect(result.css('.govuk-label').text).to eq 'What type of degree is it?'
      expect(result.css('.govuk-hint').text).to eq t('application_form.degree.international_qualification_type.hint_text')
    end
  end
end
