require 'rails_helper'

RSpec.describe GetIncompletePersonalStatementApplicationsReadyToNudge do
  it 'includes unsubmitted application with between 1-4 draft application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      becoming_a_teacher_completed: false,
    )
    create_list(:application_choice, 4, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form])
  end

  it 'omits unsubmitted applications with > 4 application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      becoming_a_teacher_completed: false,
    )
    create_list(:application_choice, 5, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits unsubmitted applications with 1-4 draft application choices that have not completed references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      becoming_a_teacher_completed: true,
      references_completed: false,
    )
    create_list(:application_choice, 4, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications with 1-4 draft application choices where personal statements are marked as completed' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      becoming_a_teacher_completed: true,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 8.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications with 1-4 draft application choices that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      becoming_a_teacher_completed: false,
    )
    create(:application_choice, application_form:)
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
      becoming_a_teacher_completed: false,
      course_choices_completed: false,
    )
    create(:application_choice, application_form:)
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
      becoming_a_teacher_completed: false,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_personal_statement',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end
end
