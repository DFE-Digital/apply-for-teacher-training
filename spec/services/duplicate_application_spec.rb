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
        recruitment_cycle_year:,
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

  let(:target_phase) { 'apply_1' }
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

  context 'when carry over from old HESA years' do
    context 'when field is hesa sex' do
      {
        2020 => [
          {
            hesa_sex: '1',
            sex: 'female',
          },
          {
            hesa_sex: '2',
            sex: 'male',
          },
          {
            hesa_sex: nil,
            sex: 'Prefer not to say',
            expected_hesa_sex: nil,
            expected_sex: 'Prefer not to say',
          },
        ],
        2021 => [
          {
            hesa_sex: '1',
            sex: 'female',
          },
          {
            hesa_sex: '2',
            sex: 'male',
          },
          {
            hesa_sex: nil,
            sex: 'Prefer not to say',
            expected_hesa_sex: nil,
            expected_sex: 'Prefer not to say',
          },
          {
            hesa_sex: '3',
            sex: 'Intersex',
            expected_hesa_sex: '12',
            expected_sex: 'other',
          },
        ],
        2022 => [
          {
            hesa_sex: '1',
            sex: 'female',
          },
          {
            hesa_sex: '2',
            sex: 'male',
          },
          {
            hesa_sex: '3',
            sex: 'intersex',
            expected_hesa_sex: '12',
            expected_sex: 'other',
          },
          {
            hesa_sex: nil,
            sex: 'Prefer not to say',
            expected_hesa_sex: nil,
            expected_sex: 'Prefer not to say',
          },
        ],
        2023 => [
          {
            hesa_sex: '1',
            sex: 'female',
          },
          {
            hesa_sex: '10',
            sex: 'female',
          },
          {
            hesa_sex: '2',
            sex: 'male',
          },
          {
            hesa_sex: '11',
            sex: 'male',
          },
          {
            hesa_sex: '12',
            sex: 'other',
          },
          {
            hesa_sex: nil,
            sex: 'Prefer not to say',
            expected_hesa_sex: nil,
            expected_sex: 'Prefer not to say',
          },
        ],
      }.each do |recruitment_cycle, sex_data|
        sex_data.each do |equality_hash|
          it "converts old hesa codes from #{recruitment_cycle} cycle for '#{equality_hash[:sex]}' into the most up to date HESA codes" do
            @original_application_form.update!(
              recruitment_cycle_year: recruitment_cycle,
              equality_and_diversity: @original_application_form.equality_and_diversity.merge(
                hesa_sex: equality_hash[:hesa_sex],
                sex: equality_hash[:sex],
              ),
            )
            hesa_sex = Hesa::Sex.find(equality_hash[:sex], recruitment_cycle_year)

            expect(duplicate_application_form.equality_and_diversity['hesa_sex']).to eq(
              equality_hash[:expected_hesa_sex] || hesa_sex&.hesa_code,
            )
            expect(duplicate_application_form.equality_and_diversity['sex']).to eq(
              equality_hash[:expected_sex] || hesa_sex&.type,
            )
          end
        end
      end
    end

    context 'when field is hesa disabilities' do
    end

    context 'when field is hesa ethnicities' do
    end
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
