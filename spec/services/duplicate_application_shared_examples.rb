require 'rails_helper'

RSpec.shared_examples 'duplicates application form' do |expected_phase, expected_cycle|
  def duplicate_application_form
    return @duplicate_application_form if @duplicate_application_form

    @duplicate_application_form ||= described_class.new(original_application_form).call
  end

  it 'creates a new application form' do
    expect(duplicate_application_form.id).not_to eql original_application_form.id
    expect(duplicate_application_form.created_at).not_to eq original_application_form.created_at
    expect(duplicate_application_form.updated_at).not_to eq original_application_form.updated_at
  end

  it 'set_the_previous_application_form_id to the original application forms id' do
    expect(duplicate_application_form.previous_application_form_id).to eq original_application_form.id
  end

  it 'does not copy application choices' do
    expect(original_application_form.application_choices).to be_present
    expect(duplicate_application_form.application_choices).to be_empty
  end

  it 'resets the state to unsubmitted' do
    expect(duplicate_application_form.submitted_at).to be_nil
    expect(duplicate_application_form.course_choices_completed).to be false
  end

  it "sets the phase to `#{expected_phase}`" do
    expect(duplicate_application_form.phase).to eq expected_phase
  end

  it "sets the recruitment_cycle_year to `#{expected_cycle}`" do
    expect(duplicate_application_form.recruitment_cycle_year).to eq expected_cycle
  end

  it 'copies application references and marks them as duplicates' do
    expect(duplicate_application_form.application_references.count).to eq 2
    expect(duplicate_application_form.application_references).to all(be_feedback_provided.or(be_not_requested_yet))
    expect(duplicate_application_form.application_references.first.duplicate).to eq true
    expect(duplicate_application_form.application_references.second.duplicate).to eq true
  end

  it 'copies work and volunteering experiences' do
    expect(duplicate_application_form.application_work_experiences.count).to eq 2
    expect(duplicate_application_form.application_volunteering_experiences.count).to eq 1
  end

  it 'copies qualifications' do
    expect(duplicate_application_form.application_qualifications.count).to eq 3
  end

  it 'copies work history breaks' do
    expect(original_application_form.application_work_history_breaks).to be_present
    expect(duplicate_application_form.application_work_history_breaks.count).to eq 1
  end

  it 'creates a new support reference' do
    expect(duplicate_application_form.support_reference).to be_present
    expect(duplicate_application_form.support_reference).not_to eq original_application_form.support_reference
  end
end
