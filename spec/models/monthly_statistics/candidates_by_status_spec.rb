require 'rails_helper'

RSpec.describe MonthlyStatistics::CandidatesByStatus do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'candidates by status'" do
    candidate_one = create(:candidate)
    candidate_one_apply_one_application = create(:application_form, phase: 'apply_1', candidate: candidate_one)
    create(:application_choice, :with_recruited, application_form: candidate_one_apply_one_application)
    create(:application_choice, :awaiting_provider_decision, application_form: candidate_one_apply_one_application)
    create(:application_choice, :with_rejection, application_form: candidate_one_apply_one_application)

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

    expect(statistics).to eq(
      {
        rows: [
          {
            'Status' => 'Recruited',
            'First application' => 1,
            'Apply again' => 2,
            'Total' => 3,
          },
          {
            'Status' => 'Conditions pending',
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
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
            'First application' => 0,
            'Apply again' => 0,
            'Total' => 0,
          },
        ],
        column_totals: [1, 2, 3],
      },
    )
  end
end
