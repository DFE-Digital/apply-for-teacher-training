require 'rails_helper'

RSpec.describe GetIncompleteReferenceApplicationsReadyToNudge do
  it 'includes forms with unsubmitted application choices that have not completed their references' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'returns unsubmitted applications that are complete, with references, but the candidate has not marked as references complete' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 2,
      references_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits candidates with locked accounts' do
    candidate = create(:candidate, account_locked: true)
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 0,
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
      :unsubmitted,
      references_count: 0,
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
      :unsubmitted,
      references_count: 0,
      candidate:,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits submitted applications' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 0,
    )
    create(:application_choice, status: ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.sample, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have not completed everything except for references' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      personal_details_completed: false,
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes uk applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      first_nationality: 'British',
      efl_completed: false,
      references_completed: false,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits international applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      first_nationality: 'French',
      efl_completed: false,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits primary course applications that have not completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      science_gcse_completed: false,
      references_count: 0,
    )
    create(
      :application_choice,
      application_form:,
      course: create(:course, level: 'secondary'),
    )
    create(
      :application_choice,
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
      :unsubmitted,
      science_gcse_completed: true,
      references_completed: false,
    )
    create(
      :application_choice,
      application_form:,
      course: create(:course, level: 'secondary'),
    )
    create(
      :application_choice,
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
      :unsubmitted,
      recruitment_cycle_year: previous_year,
      references_count: 0,
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
      references_count: 0,
    )

    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_references',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes applications that have received other emails' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'some_other_template',
      application_form:,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits applications without application choices' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications from before the current recruitment cycle' do
    application_form1 = create(
      :completed_application_form,
      :unsubmitted,
      references_completed: false,
      recruitment_cycle_year: previous_year,
    )
    application_form1.update_columns(
      updated_at: 10.days.ago,
    )
    application_form2 = create(
      :completed_application_form,
      :unsubmitted,
      references_completed: false,
    )
    create(:application_choice, application_form: application_form2)
    application_form2.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form2])
  end

  it 'does not send duplicate emails' do
    application_form = create(
      :completed_application_form,
      :unsubmitted,
      references_completed: false,
    )
    create(:application_choice, :unsubmitted, application_form:)
    create(:application_choice, :unsubmitted, application_form:)

    application_form.update_columns(
      updated_at: 10.days.ago,
    )
    expect(described_class.new.call).to eq([application_form])
  end
end
