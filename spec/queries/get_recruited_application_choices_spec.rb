require 'rails_helper'

RSpec.describe GetRecruitedApplicationChoices do
  it 'returns the recruited applications to courses for the given year' do
    create(
      :application_choice,
      :declined_by_default,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    recruited_application = create(
      :application_choice,
      :recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(recruited_application)
  end

  it 'returns the previously recruited then withdrawn applications for the given year' do
    create(
      :application_choice,
      :withdrawn,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    withdrawn_application = create(
      :application_choice,
      :withdrawn,
      recruited_at: Time.zone.now,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(withdrawn_application)
  end

  it 'returns the previously recruited then deferred applications for the given year when they have not been reinstated' do
    create(
      :application_choice,
      :offer_deferred,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    deferred_application = create(
      :application_choice,
      :offer_deferred_after_recruitment,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(deferred_application)
  end

  it 'does not return reinstated deferred applications when in the next year' do
    create(
      :application_choice,
      :offer_deferred,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    create(
      :application_choice,
      :offer_deferred_after_recruitment,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to be_empty
  end

  it 'returns reinstated deferred applications that have since been recruited when in the matching year' do
    create(
      :application_choice,
      :offer_deferred,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    reinstated_application = create(
      :application_choice,
      :offer_deferred,
      :recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2022')
    expect(application_choices).to contain_exactly(reinstated_application)
  end

  it 'returns applications in the pending conditions state' do
    pending_condition_application = create(
      :application_choice,
      :pending_conditions,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(pending_condition_application)
  end

  it 'returns nothing if no applications available for year given' do
    create(
      :application_choice,
      :offer_deferred_after_recruitment,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2022')
    expect(application_choices).to be_empty
  end

  context 'when changed_since is set' do
    it 'returns the applications with updated_at timestamps after the since timestamp' do
      deferred_application = travel_temporarily_to(1.day.from_now) do
        create(
          :application_choice,
          :offer_deferred_after_recruitment,
          application_form: build(:application_form, recruitment_cycle_year: '2021'),
          current_course_option: course_option_for_year('2021'),
        )
      end

      application_choices = described_class.call(recruitment_cycle_year: '2021', changed_since: Time.zone.now)
      expect(application_choices).to contain_exactly(deferred_application)
    end

    it 'does not return the applications with updated_at timestamps before the since timestamp' do
      travel_temporarily_to(1.day.ago) do
        create(
          :application_choice,
          :offer_deferred_after_recruitment,
          application_form: build(:application_form, recruitment_cycle_year: '2021'),
          current_course_option: course_option_for_year('2021'),
        )
      end

      application_choices = described_class.call(recruitment_cycle_year: '2021', changed_since: Time.zone.now)
      expect(application_choices).to be_empty
    end
  end

  def course_option_for_year(year)
    course = create(:course, recruitment_cycle_year: year)
    create(:course_option, course:)
  end
end
