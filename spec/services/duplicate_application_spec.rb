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
        efl_completed: true,
        adviser_interruption_response: true,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: @original_application_form)
      create(:application_choice, :rejected, application_form: @original_application_form)
      create(:gcse_qualification, :skip_validate, enic_reason: nil, application_form: @original_application_form)
    end
  end

  subject(:duplicate_application_form) do
    described_class.new(@original_application_form).duplicate
  end

  let(:recruitment_cycle_year) { current_year }

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

  it 'does not carry over adviser response status' do
    expect(duplicate_application_form.adviser_interruption_response).to be_nil
  end

  context 'when candidates has degrees' do
    it 'sets university degree to true' do
      create(:degree_qualification, :bachelor, application_form: @original_application_form)
      expect(duplicate_application_form.university_degree).to be true
    end
  end

  context 'when a candidate has a published opt out preference' do
    it 'does not duplicate the preference' do
      create(:candidate_preference, :published, :opt_out, application_form: @original_application_form)
      expect(duplicate_application_form.preferences.empty?).to be true
    end
  end

  context 'when a candidate has a a published opt in preference for anywhere in england' do
    it 'duplicates the preference' do
      create(:candidate_preference, :published, :anywhere_in_england, application_form: @original_application_form)
      expect(duplicate_application_form.preferences.first)
        .to have_attributes(
          status: 'draft',
          pool_status: 'opt_in',
          training_locations: 'anywhere',
        )
    end
  end

  context 'when a candidate has a published opt in preferences with specific locations' do
    it 'duplicates the preferences and the locations' do
      candidate_preference = create(:candidate_preference, :published, :specific_locations, application_form: @original_application_form)
      create(:candidate_location_preference, :manchester, candidate_preference:)
      create(:candidate_location_preference, :liverpool, candidate_preference:)
      form = duplicate_application_form
      expect(form.preferences.first)
        .to have_attributes(
          status: 'draft',
          pool_status: 'opt_in',
          training_locations: 'specific',
        )

      expect(form.preferences.first.location_preferences.pluck(:name)).to contain_exactly('Manchester', 'Liverpool')
    end
  end

  context 'when a candidate does not have a published pool opt in or opt out preference' do
    it 'does not create a draft preference' do
      expect(duplicate_application_form.preferences.count).to eq 0
    end
  end

  context 'when candidates does not have degrees' do
    it 'does not set university degree' do
      expect(duplicate_application_form.university_degree).to be_nil
    end
  end

  context 'english proficiency' do
    it 'carries over english proficiency data where qualification is not needed' do
      create(:english_proficiency, :qualification_not_needed, application_form: @original_application_form)
      result = duplicate_application_form

      expect(result.efl_completed).to be true
      expect(result.english_proficiency.present?).to be(true)
      expect(result.english_proficiency.efl_qualification).to be_nil
    end

    it 'carries over english proficiency data with elf qualification' do
      create(:english_proficiency, :with_toefl_qualification, application_form: @original_application_form)
      result = duplicate_application_form

      expect(result.efl_completed).to be true
      expect(result.english_proficiency.present?).to be(true)
      expect(result.english_proficiency.efl_qualification.present?).to be(true)
      expect(result.english_proficiency.efl_qualification_type).to eq 'ToeflQualification'
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
