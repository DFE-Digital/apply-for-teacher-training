require 'rails_helper'

RSpec.describe MonthlyStatistics::ByAgeGroup do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by age group'" do
    application_form_21_year_old1 = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 21, 8, 31))
    application_form_21_year_old2 = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 21, 8, 31))
    application_form_21_year_old3 = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 22, 9, 1))

    application_form_22_year_old1 = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 22, 8, 31))
    application_form_22_year_old2 = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 23, 9, 1))

    application_form_23_year_old = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 23, 1, 1))

    application_form_25_to_29_year_old = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 25, 1, 1))

    application_form_30_to_34_year_old = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 30, 1, 1))

    first_application_form_40_to_44_year_old = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 44, 1, 1))
    second_application_form_40_to_44_year_old = create(:completed_application_form,
                                                       date_of_birth: Date.new(RecruitmentCycle.current_year - 44, 1, 1),
                                                       phase: 'apply_2', candidate: first_application_form_40_to_44_year_old.candidate)

    deferred_application_form_from_previous_cycle_45_to_49_year_old = create(:completed_application_form,
                                                                             date_of_birth: Date.new(RecruitmentCycle.current_year - 49, 1, 1),
                                                                             recruitment_cycle_year: RecruitmentCycle.previous_year)

    unsuccessful_application_for_65_year_old = create(:completed_application_form, date_of_birth: Date.new(RecruitmentCycle.current_year - 65, 8, 31))

    # check recruited takes precedence over deferred
    create(:application_choice, :with_recruited, application_form: application_form_21_year_old1)
    create(:application_choice, :with_deferred_offer, application_form: application_form_21_year_old1)

    # check deferred takes precedence over pending conditions and is filtered out
    create(:application_choice, :with_deferred_offer, application_form: application_form_21_year_old2)
    create(:application_choice, :with_accepted_offer, application_form: application_form_21_year_old2)

    # check pending conditions takes precedence over offer
    create(:application_choice, :with_accepted_offer, application_form: application_form_21_year_old3)
    create(:application_choice, :with_offer, application_form: application_form_21_year_old3)

    # check offer takes precedence over awaiting_provider_decision
    create(:application_choice, :with_offer, application_form: application_form_22_year_old1)
    create(:application_choice, :awaiting_provider_decision, application_form: application_form_22_year_old1)

    # check awaiting_provider_decision takes precedence over unsuccessful states
    create(:application_choice, :awaiting_provider_decision, application_form: application_form_22_year_old2)
    create(:application_choice, :with_conditions_not_met, application_form: application_form_22_year_old2)

    create(:application_choice, :awaiting_provider_decision, application_form: application_form_23_year_old)
    create(:application_choice, :with_conditions_not_met, application_form: application_form_23_year_old)

    create(:application_choice, :awaiting_provider_decision, application_form: application_form_25_to_29_year_old)
    create(:application_choice, :with_declined_offer, application_form: application_form_25_to_29_year_old)

    create(:application_choice, :awaiting_provider_decision, application_form: application_form_30_to_34_year_old)
    create(:application_choice, :with_rejection, application_form: application_form_30_to_34_year_old)

    # only counts the latest application form
    create(:application_choice, :with_rejection, application_form: first_application_form_40_to_44_year_old)
    create(:application_choice, :with_recruited, application_form: second_application_form_40_to_44_year_old)

    # counts deferred offers from the previous cycle
    create(:application_choice, :with_deferred_offer, application_form: deferred_application_form_from_previous_cycle_45_to_49_year_old)

    create(:application_choice, :with_rejection, application_form: unsuccessful_application_for_65_year_old)

    expect(statistics).to eq(
      { rows:
        [
          {
            'Age group' => '21 and under',
            'Recruited' => 1,
            'Conditions pending' => 1,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 2,
          },
          {
            'Age group' => '22',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 1,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 0,
            'Total' => 2,
          },
          {
            'Age group' => '23',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => '24',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 0,
          },
          {
            'Age group' => '25 to 29',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => '30 to 34',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => '35 to 39',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 0,
          },
          {
            'Age group' => '40 to 44',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => '45 to 49',
            'Recruited' => 0,
            'Conditions pending' => 1,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 1,
          },
          {
            'Age group' => '50 to 54',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 0,
          },
          {
            'Age group' => '55 to 59',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 0,
          },
          {
            'Age group' => '60 to 64',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 0,
            'Total' => 0,
          },
          {
            'Age group' => '65 and over',
            'Recruited' => 0,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 0,
            'Unsuccessful' => 1,
            'Total' => 1,
          },
        ],
        column_totals: [2, 2, 1, 4, 1, 10] },
    )
  end
end
