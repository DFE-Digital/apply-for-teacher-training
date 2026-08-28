require 'rails_helper'

RSpec.describe EflQualificationCardComponent, type: :component do
  let(:application_form) { create(:application_form, first_nationality: 'French') }

  context 'when the application_form has an English speaking nationality' do
    let(:application_form) { build_stubbed(:application_form, first_nationality: 'British') }
    let(:result) { render_inline(described_class.new(application_form)) }

    it 'renders nothing' do
      expect(result.text).to be_blank
    end
  end

  context 'English is my first language' do
    let(:english_proficiency) { create(:english_proficiency, :qualification_not_needed) }

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate said that English is their main language.'
      expect(result.text).not_to include 'Further details'
    end
  end

  context 'English is my first language and have efl' do
    let(:english_proficiency) { create(:english_proficiency, :with_ielts_qualification, qualification_not_needed: true) }

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate said that English is their main language.'
      expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'
      expect(result.text).not_to include 'Further details'
    end
  end

  context 'Candidate does not plan to do a language assessment' do
    let(:english_proficiency) { create(:english_proficiency, no_qualification_details: nil) }

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate does not plan to do an English as a foreign language assessment.'
      expect(result.text).not_to include 'Further details'
    end
  end

  context 'Candidate does plan to do a language assessment' do
    let(:english_proficiency) { create(:english_proficiency, no_qualification_details: 'I will do one') }

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate plans to do an English as a foreign language assessment.'
      expect(result.text).to include 'Further details'
      expect(result.text).to include 'I will do one'
    end
  end

  context 'Candidate does plan to do a language assessment with degree in english' do
    let(:english_proficiency) do
      create(
        :english_proficiency,
        no_qualification_details: 'I will do one',
        degree_taught_in_english: true,
      )
    end

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate’s degree was taught in English.'
      expect(result.text).to include 'Candidate plans to do an English as a foreign language assessment.'
      expect(result.text).to include 'Further details'
      expect(result.text).to include 'I will do one'
    end
  end

  context 'Candidate does not plan to do a language assessment with degree in english' do
    let(:english_proficiency) do
      create(
        :english_proficiency,
        no_qualification_details: nil,
        degree_taught_in_english: true,
      )
    end

    before { application_form.english_proficiency = english_proficiency }

    it 'renders the expected output' do
      result = render_inline(described_class.new(application_form))
      expect(result.text).to include 'Candidate’s degree was taught in English.'
      expect(result.text).to include 'Candidate does not plan to do an English as a foreign language assessment.'
      expect(result.text).not_to include 'Further details'
    end
  end

  context 'when the candidate has an EFL qualification' do
    context 'which is an IELTS' do
      let(:english_proficiency) { create(:english_proficiency, :with_ielts_qualification) }

      before { application_form.english_proficiency = english_proficiency }

      it 'renders the expected output' do
        result = render_inline(described_class.new(application_form))

        expect(result.text).to include 'Candidate has done an English as a foreign language assessment.'
        expect(result.text).not_to include 'Candidate said that English is not a foreign language to them.'
        expect(result.text).not_to include 'Further details'
        expect(result.text).not_to include 'Candidate does not plan to do an English as a foreign language assessment.'

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
        expect(result.text).not_to include 'Candidate said that English is not a foreign language to them.'
        expect(result.text).not_to include 'Further details'
        expect(result.text).not_to include 'Candidate does not plan to do an English as a foreign language assessment.'

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
        expect(result.text).not_to include 'Candidate said that English is not a foreign language to them.'
        expect(result.text).not_to include 'Further details'
        expect(result.text).not_to include 'Candidate does not plan to do an English as a foreign language assessment.'

        details_card = result.css('[data-qa="english-proficiency-qualification"]')
        expect(details_card.text).to include 'Cockney Rhyming Slang Proficiency Test'
        expect(details_card.text).to include '2001'
        expect(details_card.text).to include 'Score or grade'
        expect(details_card.text).to include '20'
      end
    end
  end

  describe '.details' do
    let(:component) { described_class.new(application_form) }
    let(:rendered_component) { render_inline(component) }
    let(:application_form) { create(:application_form, first_nationality: 'French') }
    let(:english_proficiency) do
      create(
        :english_proficiency,
        :no_qualification,
        no_qualification_details:,
        no_assessment_plan_details:,
      )
    end
    let(:no_qualification_details) { nil }
    let(:no_assessment_plan_details) { nil }

    before { application_form.english_proficiency = english_proficiency }

    context 'when the english proficiency has no details are given' do
      it 'returns nil' do
        expect(component.details).to be_nil

        expect(rendered_component).to have_no_text('Further details')
      end
    end

    context 'when the english proficiency has no_qualification_details' do
      let(:no_qualification_details) { 'Working on it' }

      it 'returns the no_qualification_details' do
        expect(component.details).to eq('Working on it')

        expect(rendered_component).to have_text('Further details')
        expect(rendered_component).to have_text('Working on it')
      end
    end

    context 'when the english proficiency has no_assessment_plan_details' do
      let(:no_assessment_plan_details) { 'I have no plans' }

      it 'returns the no_assessment_plan_details' do
        expect(component.details).to eq('I have no plans')

        expect(rendered_component).to have_text('Further details')
        expect(rendered_component).to have_text('I have no plans')
      end
    end
  end
end
