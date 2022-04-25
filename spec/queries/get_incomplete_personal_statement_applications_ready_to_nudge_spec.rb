require 'rails_helper'

RSpec.describe GetIncompletePersonalStatementApplicationsReadyToNudge do
  it 'includes unsubmitted applications that have no personal statement completed' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      personal_details_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form])
  end

  it 'omits unsubmitted applications that have no reference completed' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      personal_details_completed: false,
      references_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been mark the personal statement as completed' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      personal_details_completed: true,
    )
    application_form.update_columns(
      updated_at: 8.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      personal_details_completed: false,
    )
    application_form.update_columns(
      updated_at: 6.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits unsubmitted applications that have no application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      personal_details_completed: false,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that already received this email' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      personal_details_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_personal_statement',
      application_form: application_form,
    )

    expect(described_class.new.call).to eq([])
  end
end
