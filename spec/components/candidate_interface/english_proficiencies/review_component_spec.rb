require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::ReviewComponent, type: :component do
  context 'when only the qualification status "qualification_not_needed" is true' do
    let(:english_proficiency) { create(:english_proficiency, qualification_not_needed: true) }

    it 'renders only the level of English row' do
      render_inline described_class.new(english_proficiency)
      expect(rendered_content).to have_css(
        'h2.govuk-summary-card__title',
        text: 'English as a foreign language assessment',
      )
      expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
      expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'English is my first language')
    end
  end

  context 'when the qualification status "degree_taught_in_english" is true' do
    context 'when "degree_taught_in_english" is the only true qualification status' do
      let(:english_proficiency) { create(:english_proficiency, degree_taught_in_english: true) }

      it 'renders the plan on taking an English as a foreign language assessment row' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'My degree was taught in English')
        expect(rendered_content).to have_css(
          'dt.govuk-summary-list__key',
          text: 'Do you plan on taking an English as a foreign language assessment?',
        )
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'No')
      end
    end

    context 'when "no_qualification_details" are given' do
      let(:english_proficiency) do
        create(:english_proficiency, degree_taught_in_english: true, no_qualification_details: 'Work in progress')
      end

      it 'renders the "no_qualification_details"' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'My degree was taught in English')
        expect(rendered_content).to have_css(
          'dt.govuk-summary-list__key',
          text: 'Do you plan on taking an English as a foreign language assessment?',
        )
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'Yes')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Details')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: 'Work in progress',
        )
      end
    end

    context 'when the qualification status "qualification_not_needed" is true' do
      let(:english_proficiency) do
        create(:english_proficiency, degree_taught_in_english: true, qualification_not_needed: true)
      end

      it 'displays both qualification statuses' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: 'English is my first language My degree was taught in English',
        )
      end
    end

    context 'when the qualification status "degree_taught_in_english" is true' do
      let(:english_proficiency) { create(:english_proficiency, no_qualification: true) }

      it 'renders the plan on taking an English as a foreign language assessment row' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'None of these')
        expect(rendered_content).to have_css(
          'dt.govuk-summary-list__key',
          text: 'Do you plan on taking an English as a foreign language assessment?',
        )
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'No')
      end

      context 'when "no_qualification_details" are given' do
        let(:english_proficiency) do
          create(:english_proficiency, no_qualification: true, no_qualification_details: 'Work in progress')
        end

        it 'renders the "no_qualification_details"' do
          render_inline described_class.new(english_proficiency)
          expect(rendered_content).to have_css(
            'h2.govuk-summary-card__title',
            text: 'English as a foreign language assessment',
          )
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
          expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'None of these')
          expect(rendered_content).to have_css(
            'dt.govuk-summary-list__key',
            text: 'Do you plan on taking an English as a foreign language assessment?',
          )
          expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'Yes')
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Details')
          expect(rendered_content).to have_css(
            'dd.govuk-summary-list__value',
            text: 'Work in progress',
          )
        end
      end
    end
  end

  context 'when the qualification status "has_qualification" is true' do
    let(:efl_qualification) { create(:ielts_qualification, band_score: '2') }

    context 'when only the qualification status "has_qualification" is true' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_ielts_qualification,
          has_qualification: true,
          efl_qualification:,
        )
      end

      it 'renders the qualification rows' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: 'I have an English as a foreign language (EFL) assessment',
        )
        expect(rendered_content).to have_css(
          'dt.govuk-summary-list__key',
          text: 'Type of assessment',
        )
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'IELTS')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Test report form (TRF) number')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: efl_qualification.trf_number,
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Overall band score')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: '2')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Year completed')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.award_year)
      end
    end

    context 'when the qualification status "qualification_not_needed" is true' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_ielts_qualification,
          has_qualification: true,
          qualification_not_needed: true,
          efl_qualification:,
        )
      end

      it 'displays both qualification statuses' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: 'English is my first language I have an English as a foreign language (EFL) assessment',
        )
        expect(rendered_content).to have_css(
          'dt.govuk-summary-list__key',
          text: 'Type of assessment',
        )
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'IELTS')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Test report form (TRF) number')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: efl_qualification.trf_number,
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Overall band score')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: '2')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Year completed')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.award_year)
      end

      context 'when the qualification status "degree_taught_in_english" is true' do
        let(:english_proficiency) do
          create(
            :english_proficiency,
            :with_ielts_qualification,
            has_qualification: true,
            qualification_not_needed: true,
            degree_taught_in_english: true,
            efl_qualification:,
          )
        end

        it 'displays all true qualification statuses' do
          render_inline described_class.new(english_proficiency)
          expect(rendered_content).to have_css(
            'h2.govuk-summary-card__title',
            text: 'English as a foreign language assessment',
          )
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
          expect(rendered_content).to have_css(
            'dd.govuk-summary-list__value',
            text: 'English is my first language I have an English as a foreign language (EFL) assessment My degree was taught in English',
          )
          expect(rendered_content).to have_css(
            'dt.govuk-summary-list__key',
            text: 'Type of assessment',
          )
          expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'IELTS')
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Test report form (TRF) number')
          expect(rendered_content).to have_css(
            'dd.govuk-summary-list__value',
            text: efl_qualification.trf_number,
          )
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Overall band score')
          expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: '2')
          expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Year completed')
          expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.award_year)

          expect(rendered_content).to have_no_css(
            'dt.govuk-summary-list__key',
            text: 'Do you plan on taking an English as a foreign language assessment?',
          )
          expect(rendered_content).to have_no_css('dd.govuk-summary-list__value', text: 'No')
        end
      end
    end

    context 'when the efl qualification is a TOEFL' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_toefl_qualification,
          has_qualification: true,
          efl_qualification:,
        )
      end
      let(:efl_qualification) { create(:toefl_qualification, total_score: 5) }

      it 'renders the qualification rows' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value',
                                             text: 'I have an English as a foreign language (EFL) assessment')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Type of assessment')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: 'TOEFL')
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'TOEFL registration number')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: efl_qualification.registration_number,
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Year completed')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.award_year)
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Total score')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.total_score)
      end
    end

    context 'when the efl qualification is not a IELTS or TOEFL' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_other_efl_qualification,
          has_qualification: true,
          efl_qualification:,
        )
      end
      let(:efl_qualification) { create(:other_efl_qualification) }

      it 'renders the qualification rows' do
        render_inline described_class.new(english_proficiency)
        expect(rendered_content).to have_css(
          'h2.govuk-summary-card__title',
          text: 'English as a foreign language assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Proving your level of English')
        expect(rendered_content).to have_css(
          'dd.govuk-summary-list__value',
          text: 'I have an English as a foreign language (EFL) assessment',
        )
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Type of assessment')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.name)
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Assessment name')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.name)
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Score or grade')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.grade)
        expect(rendered_content).to have_css('dt.govuk-summary-list__key', text: 'Year completed')
        expect(rendered_content).to have_css('dd.govuk-summary-list__value', text: efl_qualification.award_year)
      end
    end
  end
end
