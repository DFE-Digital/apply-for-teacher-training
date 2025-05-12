require 'rails_helper'

RSpec.describe GetUnsubmittedApplicationsReadyToNudge do
  it 'returns applications that are complete and at least one choice is unsubmitted' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits candidates with locked accounts' do
    candidate = create(:candidate, account_locked: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      candidate:,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits candidates with submission blocked' do
    candidate = create(:candidate, submission_blocked: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      candidate:,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits candidates who have unsubscribed from emails' do
    candidate = create(:candidate, unsubscribed_from_emails: true)
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      candidate:,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits submitted applications where no choices are "unsubmitted"' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
    )
    create(:application_choice, status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.sample, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that are incomplete' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
    )
    create(:application_choice, :unsubmitted, application_form:)
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
      :unsubmitted,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes uk applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      first_nationality: 'British',
      efl_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits international applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      first_nationality: 'French',
      efl_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits primary course applications that have not completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      science_gcse_completed: false,
    )
    create(
      :application_choice,
      :unsubmitted,
      application_form:,
      course: create(:course, level: 'secondary'),
    )
    create(
      :application_choice,
      :unsubmitted,
      application_form:,
      course: create(:course, level: 'primary'),
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes primary course applications that have completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      science_gcse_completed: true,
    )
    create(
      :application_choice,
      :unsubmitted,
      application_form:,
      course: create(:course, level: 'secondary'),
    )
    create(
      :application_choice,
      :unsubmitted,
      application_form:,
      course: create(:course, level: 'primary'),
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits applications that were started in a previous cycle' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
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
      :unsubmitted,
    )
    application_form.update_columns(updated_at: 10.days.ago)
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications without draft course choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
      first_nationality: 'British',
      efl_completed: false,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq([])
  end

  it 'does not send duplicate emails' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      :unsubmitted,
    )
    create(:application_choice, :unsubmitted, application_form:)
    create(:application_choice, :unsubmitted, application_form:)

    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    expect(described_class.new.call).to eq([application_form])
  end
end
