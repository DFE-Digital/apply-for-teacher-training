require 'rails_helper'

RSpec.describe GetUnsubmittedApplicationsReadyToNudge do
  it 'returns unsubmitted applications that are complete with 1-4 draft choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
    )
    create_list(:application_choice, 4, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits unsubmitted applications that are complete without draft choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq []
  end

  it 'omits unsubmitted applications that are complete with > 4 draft choices' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
    )
    create_list(:application_choice, 5, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq []
  end

  it 'omits submitted applications that are complete' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: 10.days.ago,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that are incomplete' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
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
    )
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes uk applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      first_nationality: 'British',
      efl_completed: false,
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
      :with_completed_references,
      submitted_at: nil,
      first_nationality: 'French',
      efl_completed: false,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits primary course applications that have not completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
      science_gcse_completed: false,
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
      :with_completed_references,
      submitted_at: nil,
      science_gcse_completed: true,
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
      :with_completed_references,
      submitted_at: nil,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
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
end
