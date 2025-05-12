require 'rails_helper'

RSpec.describe ProviderInterface::FindCandidates::EflQualificationCardComponent, type: :component do
  context 'when the application_form has an English speaking nationality' do
    it 'renders nothing' do
      application_form = build_stubbed(:application_form, first_nationality: 'British')
      render_inline(described_class.new(application_form))
      expect(page.text).to eq ''
    end
  end

  context 'when the application_form does not have an English speaking nationality' do
    let(:application_form) { create(:application_form, first_nationality: 'French') }

    context 'when the candidate has an EFL qualification' do
      context 'which is an IELTS' do
        it 'renders the expected output' do
          create(:english_proficiency, :with_ielts_qualification, application_form:)
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          expect(result.text).to include 'IELTS'
          expect(result.text).to include '1999'
          expect(result.text).to include 'Overall band score'
          expect(result.text).to include '6.5'
          expect(result.text).to include 'TRF number'
          expect(result.text).to include '123456'
        end
      end

      context 'which is a TOEFL' do
        it 'renders the expected output' do
          create(:english_proficiency, :with_toefl_qualification, application_form:)
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          expect(result.text).to include 'TOEFL'
          expect(result.text).to include '1999'
          expect(result.text).to include 'Total score'
          expect(result.text).to include '20'
          expect(result.text).to include 'Registration number'
          expect(result.text).to include '123456'
        end
      end

      context 'which is an "Other" qualification' do
        it 'renders the expected output' do
          create(:english_proficiency, :with_other_efl_qualification, application_form:)
          result = render_inline(described_class.new(application_form))

          expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'

          expect(result.text).to include 'Cockney Rhyming Slang Proficiency Test'
          expect(result.text).to include '2001'
          expect(result.text).to include 'Score or grade'
          expect(result.text).to include '20'
        end
      end
    end

    context 'when the candidate does not have an EFL qualification' do
      it 'renders the expected output' do
        create(
          :english_proficiency,
          :no_qualification,
          application_form:,
          no_qualification_details: 'Waiting for results',
        )
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'Candidate has not done an English as a foreign language assessment yet.'
        expect(result.text).to include 'Waiting for results'
      end
    end

    context 'when the candidate declares they do not need an EFL qualification' do
      it 'renders the expected output' do
        create(:english_proficiency, :qualification_not_needed, application_form:)
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'Candidate said that English is not a foreign language to them'
      end
    end
  end
end
