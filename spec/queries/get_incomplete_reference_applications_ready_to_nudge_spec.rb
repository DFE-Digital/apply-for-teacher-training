require 'rails_helper'

RSpec.describe GetIncompleteReferenceApplicationsReadyToNudge do
  before do
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR))
  end

  it 'returns unsubmitted applications that are complete except for having no references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'returns unsubmitted applications that are complete except for having only one requested references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 1,
      references_state: :feedback_requested,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'returns unsubmitted applications that are complete except for having only one provided references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 1,
      references_state: :feedback_provided,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits unsubmitted applications that have 2 requested references' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 2,
      references_state: :feedback_requested,
    )
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

  it 'omits applications that have been edited in the past week' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 5.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'includes uk applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      first_nationality: 'British',
      efl_completed: false,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to include(application_form)
  end

  it 'omits international applications that have not completed EFL section' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      first_nationality: 'French',
      efl_completed: false,
      references_count: 0,
    )
    application_form.update_columns(
      updated_at: 10.days.ago,
    )

    expect(described_class.new.call).to eq([])
  end

  it 'omits primary course applications that have not completed GCSE Science section' do
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

  it 'includes primary course applications that have completed GCSE Science section' do
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

  it 'omits applications that were started in a previous cycle' do
    application_form = create(
      :completed_application_form,
      submitted_at: nil,
      recruitment_cycle_year: RecruitmentCycle.previous_year,
      references_count: 0,
    )
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
    application_form.update_columns(updated_at: 10.days.ago)
    create(
      :email,
      mailer: 'candidate_mailer',
      mail_template: 'nudge_unsubmitted_with_incomplete_references',
      application_form:,
    )

    expect(described_class.new.call).to eq([])
  end

  context 'when the new_references_flow feature is inactive after 2022' do
    before { FeatureFlag.deactivate(:new_references_flow) }

    it 'includes applications for the current recruitment cycle' do
      TestSuiteTimeMachine.travel_temporarily_to(2022, 10, 5) do # 2023 recruitment cycle
        application_form = create(
          :completed_application_form,
          submitted_at: nil,
          recruitment_cycle_year: RecruitmentCycle.current_year,
          references_count: 0,
        )
        application_form.update_columns(
          updated_at: 10.days.ago,
        )

        expect(described_class.new.call).to eq([application_form])
      end
    end
  end

  context 'when the new_references_flow feature is active' do
    before { FeatureFlag.activate(:new_references_flow) }

    it 'omits applications after the 2022 recruitment cycle' do
      application_form1 = create(
        :completed_application_form,
        submitted_at: nil,
        recruitment_cycle_year: ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1,
        references_count: 0,
      )
      application_form1.update_columns(
        updated_at: 10.days.ago,
      )
      application_form2 = create(
        :completed_application_form,
        submitted_at: nil,
        recruitment_cycle_year: ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR,
        references_count: 0,
      )
      application_form2.update_columns(
        updated_at: 10.days.ago,
      )

      expect(described_class.new.call).to eq([application_form2])
    end
  end
end
