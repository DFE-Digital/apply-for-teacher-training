require 'rails_helper'

RSpec.describe GetUnsubmittedApplicationsReadyToNudge do
  it 'returns unsubmitted applications that are complete' do
    application_form = create(
      :completed_application_form,
      :with_completed_references,
      submitted_at: nil,
    )
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to include(application_form)
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

  it 'omits applications that already received this email'
end
