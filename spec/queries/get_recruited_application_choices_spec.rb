require 'rails_helper'

RSpec.describe GetRecruitedApplicationChoices do
  include CourseOptionHelpers

  it 'returns the recruited applications for the given year' do
    create(
      :application_choice,
      :with_declined_by_default_offer,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    recruited_application = create(
      :application_choice,
      :with_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(recruited_application)
  end

  it 'returns the previously recruited then withdrawn applications for the given year' do
    create(
      :application_choice,
      :withdrawn,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    withdrawn_application = create(
      :application_choice,
      :withdrawn,
      recruited_at: Time.zone.now,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(withdrawn_application)
  end

  it 'returns the the previously recruited then deferred applications for the given year' do
    create(
      :application_choice,
      :with_deferred_offer,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    deferred_application = create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2021')
    expect(application_choices).to contain_exactly(deferred_application)
  end

  it 'returns nothing if no applications available for year given' do
    create(
      :application_choice,
      :with_deferred_offer_previously_recruited,
      application_form: build(:application_form, recruitment_cycle_year: '2021'),
    )

    application_choices = described_class.call(recruitment_cycle_year: '2022')
    expect(application_choices).to be_empty
  end
end
