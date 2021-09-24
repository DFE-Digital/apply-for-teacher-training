require 'rails_helper'

RSpec.describe DataMigrations::BackfillRestructuredImmigrationStatus do
  it 'resets the `personal_details_completed` flag only for unsubmitted 2022 applications' do
    unsubmitted_2022_application = create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year: 2022,
      personal_details_completed: true,
      submitted_at: nil,
      first_nationality: 'French',
    )
    submitted_2022_application = create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year: 2022,
      personal_details_completed: true,
      submitted_at: 2.days.ago,
      first_nationality: 'French',
    )
    unsubmitted_2021_application = create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year: 2021,
      personal_details_completed: true,
      submitted_at: nil,
      first_nationality: 'French',
    )
    unsubmitted_2022_uk_application = create(
      :application_form,
      :minimum_info,
      recruitment_cycle_year: 2022,
      personal_details_completed: true,
      submitted_at: nil,
      first_nationality: 'British',
    )

    described_class.new.change

    expect(unsubmitted_2022_application.reload.personal_details_completed).to be(false)
    expect(submitted_2022_application.reload.personal_details_completed).to be(true)
    expect(unsubmitted_2021_application.reload.personal_details_completed).to be(true)
    expect(unsubmitted_2022_uk_application.reload.personal_details_completed).to be(true)
  end
end
