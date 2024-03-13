require 'rails_helper'

RSpec.describe GetIncompleteReferenceApplicationsReadyToNudge do
  it 'omits unsubmitted application that are complete, with no references, but no application choices' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits unsubmitted application that are complete, with no references, but greater than 4 application choices' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    create_list(:application_choice, 5, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'returns unsubmitted applications that are complete with 1-4 application choices except for having no references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'returns unsubmitted applications that are complete with 1-4 application choices except for having only one requested references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 1,
      references_state: :feedback_requested,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'returns unsubmitted applications that are complete with 1-4 application choices except for having only one provided references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 1,
      references_state: :feedback_provided,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits unsubmitted applications with 1-4 application choices that have 2 requested references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 2,
      references_state: :feedback_requested,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).not_to include(application_form)
  end

  it 'omits submitted applications' do
    application_form = create(
      :completed_application_form,
      submitted_at: 10.days.ago,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications that have not completed everything except for references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    application_form.update_columns(
      personal_details_completed: false,
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications with 1-4 application choices that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes uk applications with 1-4 application choices that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      first_nationality: 'British',
      efl_completed: false,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits international applications with 1-4 application choices that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
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

  it 'omits primary course applications with 1-4 application choices that have not completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
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

  it 'includes primary course applications with 1-4 application choices that have completed GCSE Science section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      science_gcse_completed: true,
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

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits applications with 1-4 application choices that were started in a previous cycle' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
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
      submitted_at: nil,
      references_count: 0,
    )
    create(:application_choice, application_form:)
    application_form.update_columns(updated_at: 10.days.ago)
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_references',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits applications from before the current recruitment cycle' do
    application_form1 = create(
      :completed_application_form,
      submitted_at: nil,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
      references_count: 0,
    )
    create(:application_choice, application_form: application_form1)
    application_form1.update_columns(
      updated_at: 10.days.ago,
    )
    application_form2 = create(
      :completed_application_form,
      submitted_at: nil,
      recruitment_cycle_year: RecruitmentCycle.current_year,
      references_count: 0,
    )
    create(:application_choice, application_form: application_form2)
    application_form2.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([application_form2])
  end
end
