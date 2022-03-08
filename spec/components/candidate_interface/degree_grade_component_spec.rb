require 'rails_helper'

RSpec.describe CandidateInterface::DegreeGradeComponent, type: :component do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe '#legend_helper' do
    context 'when uk_or_non_uk is uk' do
      it 'degree is completed' do
        degree_params = { uk_or_non_uk: 'uk', completed: 'Yes' }
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params)

        expect(described_class.new(wizard: wizard).legend_helper).to eq('What grade is your degree?')
      end

      it 'degree is not completed' do
        degree_params = { uk_or_non_uk: 'uk', completed: 'No' }
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params)

        expect(described_class.new(wizard: wizard).legend_helper).to eq('What grade do you expect to get?')
      end
    end

    context 'when uk_or_non_uk is non_uk' do
      it 'degree is completed' do
        degree_params = { uk_or_non_uk: 'non_uk', completed: 'Yes' }
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params)

        expect(described_class.new(wizard: wizard).legend_helper).to eq('Did your degree give a grade?')
      end

      it 'degree is not completed' do
        degree_params = { uk_or_non_uk: 'non_uk', completed: 'No' }
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params)

        expect(described_class.new(wizard: wizard).legend_helper).to eq('Will your degree give a grade?')
      end
    end
  end

  describe '#label_helper' do
    let(:degree_params) { { uk_or_non_uk: 'non_uk' } }

    context 'degree is non_uk' do
      it 'degree is completed' do
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params.merge({ completed: 'Yes' }))

        expect(described_class.new(wizard: wizard).label_helper).to eq(t('application_form.degree.grade.label.completed'))
      end

      it 'degree is not completed' do
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params.merge({ completed: 'No' }))

        expect(described_class.new(wizard: wizard).label_helper).to eq(t('application_form.degree.grade.label.not_completed'))
      end
    end
  end

  describe '#hint_helper' do
    let(:degree_params) { { uk_or_non_uk: 'non_uk' } }

    context 'when degree is non_uk' do
      it 'renders a hint if degree is not complete' do
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params.merge({ completed: 'No' }))

        expect(described_class.new(wizard: wizard).hint_helper).to eq(t('application_form.degree.grade.hint.not_completed'))
      end

      it 'does not render a hint if degree is complete' do
        wizard = CandidateInterface::DegreeWizard.new(store, degree_params.merge({ completed: 'Yes' }))

        expect(described_class.new(wizard: wizard).hint_helper).to be_nil
      end
    end
  end

  describe 'rendered component' do
    context 'uk' do
      let(:degree_params) { { uk_or_non_uk: 'uk' } }
      let(:wizard) { CandidateInterface::DegreeWizard.new(store, degree_params) }

      it 'renders grade choices for uk degree' do
        result = render_inline(described_class.new(wizard: wizard))

        expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(6)
        expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text)).to include(*described_class::UK_DEGREE_GRADES)
      end
    end

    context 'non_uk' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk' } }
      let(:wizard) { CandidateInterface::DegreeWizard.new(store, degree_params) }

      it 'renders options for non_uk degree' do
        result = render_inline(described_class.new(wizard: wizard))

        expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(3)
        expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text)).to include('Yes', 'No', 'I do not know')
      end
    end
  end
end
