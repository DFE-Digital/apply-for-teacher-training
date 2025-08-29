require 'rails_helper'

RSpec.describe CandidateInterface::DegreeGradeComponent, type: :component do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe '#legend_helper' do
    context 'when uk_or_non_uk is uk' do
      context 'when degree type has specific grades' do
        it 'degree is completed' do
          degree_params = {
            uk_or_non_uk: 'uk',
            completed: 'Yes',
            degree_level: 'bachelor',
            type: 'Bachelor of Engineering',
          }
          model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
          render_inline(described_class.new(model:))
          expect(page).to have_css(
            '.govuk-fieldset__legend', text: 'What grade is your degree?'
          )
        end

        it 'degree is not completed' do
          degree_params = {
            uk_or_non_uk: 'uk',
            completed: 'No',
            degree_level: 'bachelor',
            type: 'Bachelor of Engineering',
          }
          model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
          render_inline(described_class.new(model:))

          expect(page).to have_css(
            '.govuk-fieldset__legend', text: 'What grade do you expect to get?'
          )
        end
      end

      context 'when degree type has optional free-text grade' do
        it 'degree is completed' do
          degree_params = {
            uk_or_non_uk: 'uk',
            completed: 'Yes',
            degree_level: 'foundation',
            type: 'Foundation of Sciences',
          }
          model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
          render_inline(described_class.new(model:))

          expect(page).to have_css(
            '.govuk-fieldset__legend', text: 'Did this qualification give a grade?'
          )
        end

        it 'degree is not completed' do
          degree_params = {
            uk_or_non_uk: 'uk',
            completed: 'No',
            degree_level: 'Foundation degree',
            type: 'Foundation of Sciences',
          }
          model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
          render_inline(described_class.new(model:))

          expect(page).to have_css(
            '.govuk-fieldset__legend', text: 'Will this qualification give a grade?'
          )
        end
      end
    end

    context 'when uk_or_non_uk is non_uk' do
      it 'degree is completed' do
        degree_params = { uk_or_non_uk: 'non_uk', completed: 'Yes' }
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
        render_inline(described_class.new(model:))

        expect(page).to have_css(
          '.govuk-fieldset__legend', text: 'Did your degree give a grade?'
        )
      end

      it 'degree is not completed' do
        degree_params = { uk_or_non_uk: 'non_uk', completed: 'No' }
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params)
        render_inline(described_class.new(model:))

        expect(page).to have_css(
          '.govuk-fieldset__legend', text: 'Will your degree give a grade?'
        )
      end
    end
  end

  describe '#label_helper' do
    let(:degree_params) { { uk_or_non_uk: 'non_uk' } }

    context 'degree is non_uk' do
      it 'degree is completed' do
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params.merge({ completed: 'Yes' }))
        render_inline(described_class.new(model:))

        expect(page).to have_css(
          '.govuk-radios label', text: t('application_form.degree.grade.label.completed')
        )
      end

      it 'degree is not completed' do
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params.merge({ completed: 'No' }))
        render_inline(described_class.new(model:))

        expect(page).to have_css(
          '.govuk-radios label', text: t('application_form.degree.grade.label.not_completed')
        )
      end
    end
  end

  describe '#hint_helper' do
    let(:degree_params) { { uk_or_non_uk: 'non_uk' } }

    context 'when degree is non_uk' do
      it 'renders a hint if degree is not complete' do
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params.merge({ completed: 'No' }))
        render_inline(described_class.new(model:))

        expect(page).to have_css(
          '.govuk-hint', text: t('application_form.degree.grade.hint.not_completed')
        )
      end

      it 'does not render a hint if degree is complete' do
        model = CandidateInterface::Degrees::GradeForm.new(store, degree_params.merge({ completed: 'Yes' }))
        render_inline(described_class.new(model:))

        expect(page).to have_no_css('.govuk-hint')
      end
    end
  end

  describe 'rendered component' do
    context 'uk' do
      let(:degree_params) { { uk_or_non_uk: 'uk', degree_level: degree_level } }
      let(:model) { CandidateInterface::Degrees::GradeForm.new(store, degree_params) }

      context 'undergraduate degree' do
        let(:degree_level) { 'bachelor' }

        it 'renders grade choices for uk undergraduate degree' do
          result = render_inline(described_class.new(model:))

          expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(6)
          expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text))
            .to include(*CandidateInterface::Degrees::BaseForm::UK_BACHELORS_DEGREE_GRADES)
        end
      end

      context 'masters degree' do
        let(:degree_level) { 'master' }

        it 'renders grade choices for uk masters degree' do
          result = render_inline(described_class.new(model:))

          expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(4)
          expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text))
            .to include(*CandidateInterface::Degrees::BaseForm::UK_MASTERS_DEGREE_GRADES)
        end
      end
    end

    context 'non_uk' do
      let(:degree_params) { { uk_or_non_uk: 'non_uk' } }
      let(:model) { CandidateInterface::Degrees::GradeForm.new(store, degree_params) }

      it 'renders options for non_uk degree' do
        result = render_inline(described_class.new(model:))

        expect(result.css('.govuk-radios > .govuk-radios__item').count).to eq(3)
        expect(result.css(:label, '#govuk-label govuk-radios__label').map(&:text)).to include('Yes', 'No', 'I do not know')
      end
    end
  end
end
