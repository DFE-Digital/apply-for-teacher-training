require 'rails_helper'

RSpec.describe DuplicateApplication do
  before do
    travel_temporarily_to(-1.day) do
      @original_application_form = create(
        :completed_application_form,
        :with_gcses,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
        recruitment_cycle_year: RecruitmentCycle.current_year,
        references_count: 0,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
      create(:application_choice, :rejected, application_form: @original_application_form)
    end
  end

  subject(:duplicate_application_form) do
    described_class.new(@original_application_form, target_phase:).duplicate
  end

  let(:target_phase) { 'apply_2' }

  context 'application form is unsuccessful' do
    it 'copies application references' do
      create(:reference, feedback_status: :not_requested_yet, application_form: @original_application_form)
      allow(@original_application_form).to receive(:ended_without_success?).and_return(true)

      expect(duplicate_application_form.application_references.count).to eq 3
      expect(duplicate_application_form.application_references).to all(be_feedback_provided.or(be_not_requested_yet))
    end
  end

  context 'application form is unsubmitted' do
    it 'copies application references' do
      @original_application_form.update!(submitted_at: nil)
      create(:reference, feedback_status: :feedback_requested, application_form: @original_application_form)
      allow(@original_application_form).to receive(:ended_without_success?).and_return(false)

      expect(duplicate_application_form.application_references.count).to eq 3
      expect(duplicate_application_form.application_references).to all(be_feedback_provided.or(be_not_requested_yet))
    end
  end

  context 'when carry-over' do
    let(:target_phase) { 'apply_1' }

    it 'marks reference as incomplete' do
      expect(duplicate_application_form).not_to be_references_completed
    end

    it 'marks the personal statement as completed' do
      expect(duplicate_application_form).to be_becoming_a_teacher_completed
    end

    it 'merges the personal statement' do
      expect(duplicate_application_form.becoming_a_teacher).to eq @original_application_form.becoming_a_teacher
    end
  end

  context 'when apply-again' do
    let(:target_phase) { 'apply_2' }

    it 'marks reference as complete' do
      expect(duplicate_application_form).to be_references_completed
    end

    context 'when the candidate has cancelled references' do
      context 'all references are cancelled' do
        before do
          @original_application_form.application_references.each(&:cancelled!)
        end

        it 'does not transfer any references' do
          expect(duplicate_application_form.application_references.count).to eq 0
        end

        it 'marks reference as incomplete' do
          expect(duplicate_application_form).not_to be_references_completed
        end
      end

      context 'some references are cancelled and candidate has one valid' do
        before do
          @original_application_form.application_references[1..].each(&:cancelled!)
        end

        it 'transfers one reference' do
          expect(duplicate_application_form.application_references.count).to eq 1
        end

        it 'marks reference as incomplete' do
          expect(duplicate_application_form).not_to be_references_completed
        end
      end

      context 'some references are cancelled but candidate still has two valid' do
        before do
          @original_application_form.application_references.last.cancelled!
        end

        it 'transfers two references' do
          expect(duplicate_application_form.application_references.count).to eq 2
        end

        it 'marks reference as complete' do
          expect(duplicate_application_form).to be_references_completed
        end
      end
    end
  end
end
