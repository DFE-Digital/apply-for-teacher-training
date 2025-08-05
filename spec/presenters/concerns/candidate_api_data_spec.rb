require 'rails_helper'

RSpec.describe CandidateAPIData do
  subject(:presenter) { CandidateClass.new(application_choice) }

  let(:candidate_class) do
    Class.new do
      include CandidateAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('CandidateClass', candidate_class)
  end

  describe '#candidate' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, application_form:) }

    describe '#uk_residency_status' do
      context 'when the candidates nationalities include UK' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Irish', second_nationality: 'British') }

        it 'returns UK Citizen' do
          expect(presenter.candidate[:uk_residency_status]).to eq('UK Citizen')
        end
      end

      context 'when the candidates nationalities is Irish' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian', second_nationality: 'Irish') }

        it 'returns Irish Citizen' do
          expect(presenter.candidate[:uk_residency_status]).to eq('Irish Citizen')
        end
      end

      context 'when the candidates has the right to work/study in the UK' do
        let(:application_form) do
          create(:application_form,
                 :minimum_info,
                 first_nationality: 'Canadian',
                 right_to_work_or_study: 'yes',
                 right_to_work_or_study_details: 'I have Settled status')
        end

        it 'returns details of the immigration status' do
          expect(presenter.candidate[:uk_residency_status]).to eq('I have Settled status')
        end
      end

      context 'when the candidates has the right to work/study in the UK because they are EU settled' do
        let(:application_form) do
          build(:application_form,
                first_nationality: 'French',
                right_to_work_or_study: 'yes',
                immigration_status: 'eu_settled',
                right_to_work_or_study_details: nil)
        end

        it 'returns details of the immigration status' do
          expect(presenter.candidate[:uk_residency_status]).to eq('EU settled status')
        end
      end

      context 'when the candidates has the right to work/study in the UK because they are pre EU settled' do
        let(:application_form) do
          build(:application_form,
                first_nationality: 'French',
                right_to_work_or_study: 'yes',
                immigration_status: 'eu_pre_settled',
                right_to_work_or_study_details: nil)
        end

        it 'returns details of the immigration status' do
          expect(presenter.candidate[:uk_residency_status]).to eq('EU pre-settled status')
        end
      end

      context 'when the candidates does not have the right to work/study in the UK' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'no') }

        it 'returns correct message' do
          expect(presenter.candidate[:uk_residency_status]).to eq('Candidate needs to apply for permission to work and study in the UK')
        end
      end

      context 'when the candidate does not know if they have the right to work/study in the UK' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'decide_later') }

        it 'returns correct message' do
          expect(presenter.candidate[:uk_residency_status]).to eq('Candidate needs to apply for permission to work and study in the UK')
        end
      end

      context 'when the right to work or study details go over the character limit' do
        let(:limit) { 256 }
        let(:details) { Faker::Lorem.characters(number: limit + 1) }
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'yes', right_to_work_or_study_details: details) }

        it 'returns a message with truncation omission text' do
          expect(presenter.candidate[:uk_residency_status]).to end_with(described_class::OMISSION_TEXT)
        end

        it 'returns a value within the field limit' do
          expect(presenter.candidate[:uk_residency_status].length).to be(limit)
        end
      end

      context 'when the right to work or study details is nil' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'yes', right_to_work_or_study_details: nil) }

        it 'returns nil for uk_residency_status' do
          expect(presenter.candidate[:uk_residency_status]).to be_nil
        end
      end
    end

    describe '#uk_residency_status_code' do
      let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision, application_form:) }

      context 'when one of the candidate nationalities is GB' do
        let(:application_form) { build_stubbed(:application_form, :minimum_info, first_nationality: 'Irish', second_nationality: 'British') }

        it 'returns A' do
          expect(presenter.candidate[:uk_residency_status_code]).to  eq('A')
        end
      end

      context 'when one of the candidate nationalities is IE' do
        let(:application_form) { build_stubbed(:application_form, :minimum_info, first_nationality: 'Canadian', second_nationality: 'Irish') }

        it 'returns B' do
          expect(presenter.candidate[:uk_residency_status_code]).to  eq('B')
        end
      end

      context 'when the candidate does not have residency or right to work in UK' do
        let(:application_form) { build_stubbed(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'no') }

        it 'returns C' do
          expect(presenter.candidate[:uk_residency_status_code]).to  eq('C')
        end
      end

      context 'when the candidate wishes to answer residency questions later' do
        let(:application_form) { build_stubbed(:application_form, :minimum_info, first_nationality: 'Canadian', right_to_work_or_study: 'decide_later') }

        it 'returns C' do
          expect(presenter.candidate[:uk_residency_status_code]).to  eq('C')
        end
      end

      context 'when the candidate has UK residency' do
        let(:application_form) do
          build_stubbed(:application_form,
                        :minimum_info,
                        first_nationality: 'Canadian',
                        right_to_work_or_study: 'yes',
                        right_to_work_or_study_details: 'I have Settled status')
        end

        it 'returns D' do
          expect(presenter.candidate[:uk_residency_status_code]).to eq('D')
        end
      end
    end

    describe '#domicile' do
      let(:application_form) { create(:application_form, :minimum_info) }

      it 'uses DomicileResolver to return a HESA code' do
        expect(presenter.candidate[:domicile]).to eq(application_form.domicile)
      end
    end

    describe '#fee_payer' do
      context 'when the nationality is provisionally eligible for government funding' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'British') }

        it 'returns 02' do
          expect(presenter.candidate[:fee_payer]).to eq('02')
        end
      end

      context 'when the candidate is EU, EEA or Swiss national, has the right to work/study in the UK and their domicile is the UK' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'yes') }

        it 'returns 02' do
          expect(presenter.candidate[:fee_payer]).to eq('02')
        end
      end

      context 'when the candidate is not British, Irish, EU, EEA or Swiss national' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Canadian') }

        it 'returns 99' do
          expect(presenter.candidate[:fee_payer]).to eq('99')
        end
      end

      context 'when the candidate does not have the right to work/study in the UK' do
        let(:application_form) { create(:application_form, :minimum_info, first_nationality: 'Swiss', right_to_work_or_study: 'no') }

        it 'returns 99' do
          expect(presenter.candidate[:fee_payer]).to eq('99')
        end
      end

      context 'when the candidate does not reside in the UK' do
        let(:application_form) { create(:application_form, :minimum_info, :international_address, first_nationality: 'Swiss', right_to_work_or_study: 'yes') }

        it 'returns 99' do
          expect(presenter.candidate[:fee_payer]).to eq('99')
        end
      end
    end

    describe '#english_language_qualifications', :wip do
      let(:english_proficiency) { create(:english_proficiency, :with_toefl_qualification) }
      let(:application_form) { create(:completed_application_form, english_proficiency:) }

      context 'default' do
        it 'returns a description of the candidate\'s EFL qualification' do
          expect(presenter.candidate[:english_language_qualifications]).to eq('Name: TOEFL, Grade: 20, Awarded: 1999, Reference: 123456')
        end
      end

      context 'when the deprecated field english_language_details is set' do
        let(:application_form) do
          create(:completed_application_form,
                 english_proficiency:,
                 english_language_details: 'I have taken some exams but I do not remember the names')
        end

        it 'returns the description of the candidate\'s EFL qualification over it' do
          expect(presenter.candidate[:english_language_qualifications]).to eq('Name: TOEFL, Grade: 20, Awarded: 1999, Reference: 123456')
        end
      end

      context 'when no EFL qualifications are provided' do
        let(:application_form) do
          create(:completed_application_form,
                 english_language_details: 'I have taken some exams but I do not remember the names')
        end

        it 'returns english_language_details' do
          expect(presenter.candidate[:english_language_qualifications]).to eq('I have taken some exams but I do not remember the names')
        end
      end
    end
  end
end
