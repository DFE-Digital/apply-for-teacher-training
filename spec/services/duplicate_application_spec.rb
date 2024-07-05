require 'rails_helper'

RSpec.describe DuplicateApplication do
  before do
    travel_temporarily_to(-1.day) do
      @original_application_form = create(
        :completed_application_form,
        :with_gcses,
        :with_equality_and_diversity_data,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
        recruitment_cycle_year:,
        references_count: 0,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
      create(:application_choice, :rejected, application_form: @original_application_form)
    end
  end

  subject(:duplicate_application_form) do
    described_class.new(@original_application_form).duplicate
  end

  let(:recruitment_cycle_year) { RecruitmentCycle.current_year }

  it 'marks reference as incomplete' do
    expect(duplicate_application_form).not_to be_references_completed
  end

  it 'marks the personal statement as completed' do
    expect(duplicate_application_form).to be_becoming_a_teacher_completed
  end

  it 'merges the personal statement' do
    expect(duplicate_application_form.becoming_a_teacher).to eq @original_application_form.becoming_a_teacher
  end

  it 'does not carry over any equality and diversity data' do
    expect(duplicate_application_form.equality_and_diversity).to be_nil
    expect(duplicate_application_form.equality_and_diversity_completed).to be_nil
  end

  context 'when application form is unsuccessful' do
    before do
      create(:reference, feedback_status: :not_requested_yet, application_form: @original_application_form)
      allow(@original_application_form).to receive(:ended_without_success?).and_return(true)
    end

    it 'copies application references' do
      expect(duplicate_application_form.application_references.count).to eq 3
      expect(duplicate_application_form.application_references).to all(be_feedback_provided.or(be_not_requested_yet))
    end
  end

  context 'when application form is unsubmitted' do
    before do
      @original_application_form.update!(submitted_at: nil)
      create(:reference, feedback_status: :feedback_requested, application_form: @original_application_form)
      allow(@original_application_form).to receive(:ended_without_success?).and_return(false)
    end

    it 'copies application references' do
      expect(duplicate_application_form.application_references.count).to eq 3
      expect(duplicate_application_form.application_references).to all(be_feedback_provided.or(be_not_requested_yet))
    end
  end
end
