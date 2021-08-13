require 'rails_helper'

RSpec.describe EflQualificationCardComponent, type: :component do
  context 'when the application_form has an English speaking nationality' do
    let(:application_form) { build_stubbed(:application_form, first_nationality: 'British') }
    let(:result) { render_inline(described_class.new(application_form)) }

    it 'renders nothing' do
      expect(result.text).to be_blank
    end
  end

  context 'when the application_form does not have an English speaking nationality' do
    let(:application_form) { create(:application_form, first_nationality: 'French') }

    context 'when the candidate has an EFL qualification' do
      context 'which is an IELTS' do
        let(:english_proficiency) { create(:english_proficiency, :with_ielts_qualification) }

        before { application_form.english_proficiency = english_proficiency }

        it 'renders the expected output' do
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          details_card = result.css('[data-qa="english-proficiency-qualification"]')
          expect(details_card.text).to include 'IELTS'
          expect(details_card.text).to include '1999'
          expect(details_card.text).to include 'Overall band score'
          expect(details_card.text).to include '6.5'
          expect(details_card.text).to include 'TRF number'
          expect(details_card.text).to include '123456'
        end
      end

      context 'which is a TOEFL' do
        let(:english_proficiency) { create(:english_proficiency, :with_toefl_qualification) }

        before { application_form.english_proficiency = english_proficiency }

        it 'renders the expected output' do
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          details_card = result.css('[data-qa="english-proficiency-qualification"]')
          expect(details_card.text).to include 'TOEFL'
          expect(details_card.text).to include '1999'
          expect(details_card.text).to include 'Total score'
          expect(details_card.text).to include '20'
          expect(details_card.text).to include 'Registration number'
          expect(details_card.text).to include '123456'
        end
      end

      context 'which is an "Other" qualification' do
        let(:english_proficiency) { create(:english_proficiency, :with_other_efl_qualification) }

        before { application_form.english_proficiency = english_proficiency }

        it 'renders the expected output' do
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          details_card = result.css('[data-qa="english-proficiency-qualification"]')
          expect(details_card.text).to include 'Cockney Rhyming Slang Proficiency Test'
          expect(details_card.text).to include '2001'
          expect(details_card.text).to include 'Score or grade'
          expect(details_card.text).to include '20'
        end
      end
    end

    context 'when the candidate does not have an EFL qualification' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :no_qualification,
          no_qualification_details: 'Waiting for results',
        )
      end

      before { application_form.english_proficiency = english_proficiency }

      it 'renders the expected output' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'Candidate has not done an English as a foreign language assessment yet.'
        expect(result.text).to include 'Waiting for results'
        details_card = result.css('#english-as-a-foreign-language .app-card--outline')
        expect(details_card).to be_blank
      end
    end

    context 'when the candidate declares they do not need an EFL qualification' do
      let(:english_proficiency) { create(:english_proficiency, :qualification_not_needed) }

      before { application_form.english_proficiency = english_proficiency }

      it 'renders the expected output' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'Candidate said that English is not a foreign language to them'
        details_card = result.css('#english-as-a-foreign-language .app-card--outline')
        expect(details_card).to be_blank
      end
    end
  end
end
