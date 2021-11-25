require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByStatus do
  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      setup_test_data

      expect(statistics).to eq(
        {
          rows:
            [
              {
                'Status' => 'Recruited',
                'First application' => 2,
                'Apply again' => 2,
                'Total' => 4,
              },
              {
                'Status' => 'Conditions pending',
                'First application' => 1,
                'Apply again' => 0,
                'Total' => 1,
              },
              {
                'Status' => 'Received an offer but not responded',
                'First application' => 0,
                'Apply again' => 0,
                'Total' => 0,
              },
              {
                'Status' => 'Awaiting provider decisions',
                'First application' => 0,
                'Apply again' => 0,
                'Total' => 0,
              },
              {
                'Status' => 'Declined an offer',
                'First application' => 0,
                'Apply again' => 0,
                'Total' => 0,
              },
              {
                'Status' => 'Withdrew an application',
                'First application' => 0,
                'Apply again' => 0,
                'Total' => 0,
              },
              {
                'Status' => 'Application rejected',
                'First application' => 4,
                'Apply again' => 1,
                'Total' => 5,
              },
            ],
          column_totals: [7, 3, 10],
        },
      )
    end
  end

  context 'candidates by status table data' do
    subject(:statistics) { described_class.new(by_candidate: true).table_data }

    it "returns table data for 'candidates by status'" do
      setup_test_data

      expect(statistics).to eq(
        { rows: [
          {
            'Status' => 'Recruited',
            'First application' => 2,
            'Apply again' => 2,
            'Total' => 4,
          },
          {
            'Status' => 'Conditions pending',
            'First application' => 1,
            'Apply again' => 0,
            'Total' => 1,
          },
          {
            'Status' => 'Received an offer but not responded',
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
          },
          {
            'Status' => 'Awaiting provider decisions',
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
          },
          {
            'Status' => 'Declined an offer',
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
          },
          {
            'Status' => 'Withdrew an application',
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
          },
          {
            'Status' => 'Application rejected',
            'First application' => 2,
            'Apply again' => 0,
            'Total' => 2,
          },
        ],
          column_totals: [5, 2, 7] },
      )
    end
  end

  def setup_test_data
    candidate_one = create(:candidate)
    candidate_one_apply_one_application = create(:application_form, phase: 'apply_1', candidate: candidate_one)
    create(:application_choice, :with_rejection, application_form: candidate_one_apply_one_application)
    create(:application_choice, :awaiting_provider_decision, application_form: candidate_one_apply_one_application)
    create(:application_choice, :with_recruited, application_form: candidate_one_apply_one_application)

    candidate_two = create(:candidate)
    candidate_two_apply_one_application = create(:application_form, phase: 'apply_1', candidate: candidate_two)
    create(:application_choice, :with_rejection, application_form: candidate_two_apply_one_application)
    create(:application_choice, :with_rejection, application_form: candidate_two_apply_one_application)
    create(:application_choice, :with_rejection, application_form: candidate_two_apply_one_application)
    candidate_two_apply_again_application = create(:application_form, phase: 'apply_2', candidate: candidate_two, previous_application_form_id: candidate_two_apply_one_application.id)
    create(:application_choice, :with_recruited, application_form: candidate_two_apply_again_application)
    create(:application_choice, :awaiting_provider_decision, application_form: candidate_two_apply_again_application)
    create(:application_choice, :with_rejection, application_form: candidate_two_apply_again_application)

    candidate_three = create(:candidate)
    candidate_three_apply_one_application = create(:application_form, phase: 'apply_1', candidate: candidate_three)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_one_application)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_one_application)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_one_application)
    candidate_three_apply_again_application = create(:application_form, phase: 'apply_2', candidate: candidate_three, previous_application_form_id: candidate_three_apply_one_application.id)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_again_application)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_again_application)
    create(:application_choice, :with_rejection, application_form: candidate_three_apply_again_application)
    candidate_three_second_apply_again_application = create(:application_form, phase: 'apply_2', candidate: candidate_three, previous_application_form_id: candidate_three_apply_again_application.id)
    create(:application_choice, :with_recruited, application_form: candidate_three_second_apply_again_application)
    create(:application_choice, :awaiting_provider_decision, application_form: candidate_three_second_apply_again_application)
    create(:application_choice, :with_rejection, application_form: candidate_three_second_apply_again_application)

    candidate_four = create(:candidate)
    candidate_four_apply_one_deferred_application = create(:application_form, phase: 'apply_1', candidate: candidate_four, recruitment_cycle_year: RecruitmentCycle.previous_year)
    create(:application_choice, :with_offer, :offer_deferred, status_before_deferral: 'recruited', application_form: candidate_four_apply_one_deferred_application)

    candidate_five = create(:candidate)
    candidate_five_conditions_pending_application = create(:application_form, phase: 'apply_1', candidate: candidate_five)
    create(:application_choice, :with_accepted_offer, application_form: candidate_five_conditions_pending_application)

    candidate_six = create(:candidate)
    candidate_six_withdrawn_application = create(:application_form, phase: 'apply_1', candidate: candidate_six)
    create(:application_choice, :with_withdrawn_offer, application_form: candidate_six_withdrawn_application)

    candidate_seven = create(:candidate)
    candidate_seven_conditions_not_met_application = create(:application_form, phase: 'apply_1', candidate: candidate_seven)
    create(:application_choice, :with_conditions_not_met, application_form: candidate_seven_conditions_not_met_application)
  end
end
