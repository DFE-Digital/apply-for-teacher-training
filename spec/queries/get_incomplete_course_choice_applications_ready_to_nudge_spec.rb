require 'rails_helper'

RSpec.describe GetIncompleteCourseChoiceApplicationsReadyToNudge do
  it 'includes applications that have no application choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
    )
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
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits unsubmitted applications that have an application choice' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits submitted applications' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
    )

    create(:application_choice, status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.sample, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have not completed references' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
    )
    application_form.update_columns(
      references_completed: false,
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have not completed personal statement' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
    )
    application_form.update_columns(
      becoming_a_teacher_completed: false,
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications from an earlier recruitment cycle' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      course_choices_completed: false,
      recruitment_cycle_year: previous_year,
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
      course_choices_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_courses',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end
end
