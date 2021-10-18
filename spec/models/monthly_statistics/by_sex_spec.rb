require 'rails_helper'

RSpec.describe MonthlyStatistics::BySex do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    create_application_choice(status: :with_rejection, sex: 'female')
    create_application_choice(status: :awaiting_provider_decision, sex: 'Prefer not to say')
    create_application_choice(status: :with_recruited, sex: 'Prefer not to say')
    create_application_choice(status: :with_offer, sex: 'intersex')
    create_application_choice(status: :with_deferred_offer, sex: 'male', recruitment_cycle_year: RecruitmentCycle.previous_year)
    create_application_choice(status: :with_deferred_offer, sex: 'female', recruitment_cycle_year: RecruitmentCycle.current_year)
    create_application_choice(status: :with_conditions_not_met, sex: 'intersex')
    create_application_choice(status: :with_offer, sex: 'female')
    create_application_choice_with_previous_application(status: :with_rejection, sex: 'male')

    expect(statistics).to eq(
      { rows:
        [
          {
            'Sex' => 'Female',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Sex' => 'Male',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Sex' => 'Intersex',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 2,
          },
          {
            'Sex' => 'Prefer not to say',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 0,
            'Total' => 2,
          },
        ],
        column_totals: [1, 0, 3, 1, 3, 8] },
    )
  end

  def create_application_choice(
    status:,
    sex:,
    recruitment_cycle_year: RecruitmentCycle.current_year,
    previous_application_form: nil
  )
    create(
      :application_choice,
      status,
      application_form: create(
        :application_form,
        previous_application_form: previous_application_form,
        recruitment_cycle_year: recruitment_cycle_year,
        equality_and_diversity: { 'sex' => sex },
      ),
    )
  end

  def create_application_choice_with_previous_application(
    status:,
    sex:,
    recruitment_cycle_year: RecruitmentCycle.current_year
  )
    previous_application_choice = create_application_choice(
      status: status,
      sex: sex,
      recruitment_cycle_year: recruitment_cycle_year,
    )
    create_application_choice(
      status: status,
      sex: sex,
      recruitment_cycle_year: recruitment_cycle_year,
      previous_application_form: previous_application_choice.application_form,
    )
  end
end
