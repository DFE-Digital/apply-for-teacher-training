require 'rails_helper'

RSpec.describe DuplicateApplication do
  def original_application_form
    Timecop.travel(-1.day) do
      @original_application_form ||= create(
        :completed_application_form,
        application_choices_count: 3,
        work_experiences_count: 1,
        volunteering_experiences_count: 1,
        with_gces: true,
        full_work_history: true,
      )
      create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @original_application_form)
    end
    @original_application_form
  end

  def duplicate_application_form
    return @duplicate_application_form if @duplicate_application_form

    @duplicate_application_form ||= described_class.new(original_application_form).duplicate
  end

  it 'creates a new application form' do
    expect(duplicate_application_form.id).not_to eql original_application_form.id
    expect(duplicate_application_form.created_at).not_to eq original_application_form.created_at
    expect(duplicate_application_form.updated_at).not_to eq original_application_form.updated_at
  end

  it 'does not copy application choices' do
    expect(original_application_form.application_choices).to be_present
    expect(duplicate_application_form.application_choices).to be_empty
  end

  it 'resets the state to unsubmitted' do
    expect(duplicate_application_form.submitted_at).to be_nil
    expect(duplicate_application_form.course_choices_completed).to be false
  end

  it 'sets the phase to `apply_2`' do
    expect(duplicate_application_form).to be_apply_2
  end

  it 'copies application references' do
    expect(duplicate_application_form.application_references.count).to eq 2
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
end
