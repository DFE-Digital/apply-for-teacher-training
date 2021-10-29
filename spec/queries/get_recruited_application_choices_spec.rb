require 'rails_helper'

RSpec.describe GetRecruitedApplicationChoices do
  it 'returns the recruited applications to courses for the given year' do
    create(
      :application_choice,
      :with_declined_by_default_offer,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    recruited_application = create(
      :application_choice,
      :with_recruited,
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
      :with_deferred_offer,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    deferred_application = create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(deferred_application)
  end

  it 'does not return reinstated deferred applications when in the next year' do
    create(
      :application_choice,
      :with_deferred_offer,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2022'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to be_empty
  end

  it 'returns nothing if no applications available for year given' do
    create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
      current_course_option: course_option_for_year('2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2022')
    expect(application_choices).to be_empty
  end

  context 'when changed_since is set' do
    it 'returns the applications with updated_at timestamps after the since timestamp' do
      deferred_application = create(
        :application_choice,
        :with_deferred_offer_previously_recruited,
        application_form: build(:application_form, recruitment_cycle_year: '2021'),
        current_course_option: course_option_for_year('2021'),
      )
      deferred_application.update(updated_at: Time.zone.now + 1.day)

      application_choices = described_class.call(recruitment_cycle_year: '2021', changed_since: Time.zone.now)
      expect(application_choices).to contain_exactly(deferred_application)
    end

    it 'does not return the applications with updated_at timestamps before the since timestamp' do
      create(
        :application_choice,
        :with_deferred_offer_previously_recruited,
        application_form: build(:application_form, recruitment_cycle_year: '2021'),
        current_course_option: course_option_for_year('2021'),
        updated_at: Time.zone.now - 1.day,
      )

      application_choices = described_class.call(recruitment_cycle_year: '2021', changed_since: Time.zone.now)
      expect(application_choices).to be_empty
    end
  end

  def course_option_for_year(year)
    course = create(:course, recruitment_cycle_year: year)
    create(:course_option, course: course)
  end
end
