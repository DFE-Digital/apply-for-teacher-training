require 'rails_helper'

RSpec.describe GetIncompleteCourseChoiceApplicationsReadyToNudge do
  it 'includes unsubmitted applications that have no application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form])
  end

  it 'omits unsubmitted applications that have an application choice' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    create(:application_choice, application_form: application_form)

    expect(described_class.new.call).to eq([])
  end


  it 'omits submitted applications' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: Time.zone.now,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end


  it 'omits applications that have not completed references' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      course_choices_completed: false,
    )
    application_form.update_columns(
      references_completed: false,
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that already received this email' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_courses',
      application_form: application_form,
    )

    expect(described_class.new.call).to eq([])
  end
end
