require 'rails_helper'

RSpec.describe DuplicateApplication do
  before do
    travel_temporarily_to(-1.day) do
      @original_application_form = create(
        :completed_application_form,
        :with_gcses,
        :with_equality_and_diversity_data,
        with_disability_randomness: false,
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

  context 'when carry over nil disabilities' do
    before do
      @original_application_form.update!(
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          disabilities: nil,
          hesa_disabilities: nil,
        ),
      )
    end

    it 'sets disabilities as nil' do
      expect(duplicate_application_form.equality_and_diversity['disabilities']).to be_nil
    end

    it 'sets the E&D section as incomplete and force the candidate to answer the question again.' do
      expect(duplicate_application_form).not_to be_equality_and_diversity_completed
    end
  end

  context 'when carry over empty disabilities' do
    before do
      @original_application_form.update!(
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          disabilities: [],
          hesa_disabilities: [],
        ),
      )
    end

    it 'sets disabilities as nil' do
      expect(duplicate_application_form.equality_and_diversity['disabilities']).to be_nil
    end

    it 'sets the E&D section as incomplete and force the candidate to answer the question again.' do
      expect(duplicate_application_form).not_to be_equality_and_diversity_completed
    end
  end

  context 'when carry over nil ethnic background' do
    before do
      @original_application_form.update!(
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          ethnic_background: nil,
          hesa_ethnicity: nil,
        ),
      )
    end

    it 'sets the ethnicity as nil' do
      expect(duplicate_application_form.equality_and_diversity['ethnic_background']).to be_nil
    end

    it 'sets the E&D section as incomplete' do
      expect(duplicate_application_form).not_to be_equality_and_diversity_completed
    end
  end

  context 'when carry over nil ethnicity' do
    before do
      @original_application_form.update!(
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          hesa_ethnicity: nil,
          ethnic_background: nil,
        ),
      )
    end

    it 'carries over ethnicity as blank' do
      expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to be_nil
      expect(duplicate_application_form.equality_and_diversity['ethnic_background']).to be_nil
    end

    it 'sets the E&D section as incomplete' do
      expect(duplicate_application_form).not_to be_equality_and_diversity_completed
    end
  end

  context 'when carry over old value ethnicities' do
    before do
      @original_application_form.update!(
        recruitment_cycle_year: 2022,
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          hesa_ethnicity: '10',
          ethnic_background: 'British, English, Northern Irish, Scottish, or Welsh',
        ),
      )
    end

    it 'converts HESA ethnicity' do
      expect(duplicate_application_form.equality_and_diversity['hesa_ethnicity']).to eq('160')
    end

    it 'carries over ethnic background' do
      expect(duplicate_application_form.equality_and_diversity['ethnic_background']).to eq('British, English, Northern Irish, Scottish, or Welsh')
    end

    it 'sets the E&D section as complete' do
      expect(duplicate_application_form).to be_equality_and_diversity_completed
    end
  end

  context 'convert equality and diversity from a cycle that HESA did not change' do
    before do
      @original_application_form.update!(
        recruitment_cycle_year: 2023,
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          hesa_sex: '11',
          sex: 'male',
          hesa_disabilities: ['51'],
          disabilities: ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
          hesa_ethnicity: '119',
          ethnic_group: 'Asian or Asian British',
          ethnic_background: 'Punjabi',
        ),
      )
    end

    it 'carries over equality and diversity data' do
      expect(duplicate_application_form.equality_and_diversity).to eq(
        {
          'sex' => 'male',
          'ethnic_group' => 'Asian or Asian British',
          'ethnic_background' => 'Punjabi',
          'disabilities' => ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
          'hesa_sex' => '11',
          'hesa_disabilities' => ['51'],
          'hesa_ethnicity' => '119',
        },
      )
    end

    it 'sets the E&D section as complete' do
      expect(duplicate_application_form).to be_equality_and_diversity_completed
    end
  end

  context 'when conversion returns an error' do
    it 'sets the E&D section as complete' do
      allow(Sentry).to receive(:capture_message)
      converter = instance_double(HesaConverter, hesa_sex: '10', sex: 'female', hesa_disabilities: ['96'], disabilities: ['Other'])
      allow(HesaConverter).to receive(:new).and_return(converter)
      allow(converter).to receive(:hesa_ethnicity).and_raise(StandardError)
      expect(duplicate_application_form).not_to be_equality_and_diversity_completed

      expect(Sentry).to have_received(:capture_message)

      expect(duplicate_application_form.equality_and_diversity).to include(
        'sex' => nil,
        'disabilities' => [],
        'ethnic_group' => nil,
        'ethnic_background' => nil,
      )
    end
  end

  context 'convert equality and diversity from a cycle that HESA did change' do
    before do
      @original_application_form.update!(
        recruitment_cycle_year: 2022,
        equality_and_diversity_completed: true,
        equality_and_diversity: @original_application_form.equality_and_diversity.merge(
          hesa_sex: '1',
          sex: 'male',
          hesa_disabilities: ['51'],
          disabilities: ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
          hesa_ethnicity: '10',
          ethnic_group: 'Black, African, Black British or Caribbean',
          ethnic_background: 'Black British',
        ),
      )
    end

    it 'carries over equality and diversity data' do
      expect(duplicate_application_form.equality_and_diversity).to eq(
        {
          'sex' => 'male',
          'ethnic_group' => 'Black, African, Black British or Caribbean',
          'ethnic_background' => 'Black British',
          'disabilities' => ['Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference'],
          'hesa_sex' => '11',
          'hesa_disabilities' => ['51'],
          'hesa_ethnicity' => '160',
        },
      )
    end

    it 'sets the E&D section as complete' do
      expect(duplicate_application_form).to be_equality_and_diversity_completed
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
