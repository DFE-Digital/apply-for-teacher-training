require 'rails_helper'

RSpec.describe GetIncompletePersonalStatementApplicationsReadyToNudge do
  it 'includes unsubmitted applications choices which don\'t have any completed personal statements' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form])
  end

  it 'omits candidates with locked accounts' do
    candidate = create(:candidate, account_locked: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      candidate:,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
    )

    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits candidates with submission blocked' do
    candidate = create(:candidate, submission_blocked: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      candidate:,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits candidates who have unsubscribed from emails' do
    candidate = create(:candidate, unsubscribed_from_emails: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      candidate:,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits unsubmitted applications that have not completed references' do
    application_form = create(
      :completed_application_form,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: true,
      references_completed: false,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications where personal statements are marked as completed' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: true,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 8.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 6.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have no application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: 10.days.ago,
      becoming_a_teacher_completed: false,
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
      submitted_at: 10.days.ago,
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
