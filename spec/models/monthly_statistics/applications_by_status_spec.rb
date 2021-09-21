require 'rails_helper'

RSpec.describe MonthlyStatistics::ApplicationsByStatus do
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'applications by status'" do
    # Recruited
    create_application_choice(status: :with_recruited, phase: 'apply_1')

    # Conditions pending
    create_application_choice(status: :with_conditions_not_met, phase: 'apply_1')
    create_application_choice(status: :with_deferred_offer, phase: 'apply_1')

    # Received an offer but did not respond
    create_application_choice(status: :with_offer, phase: 'apply_2')
    create_application_choice(status: :with_offer, phase: 'apply_2')

    # Awaiting provider decisions
    create_application_choice(status: :awaiting_provider_decision, phase: 'apply_2')
    create_application_choice(status: :with_scheduled_interview, phase: 'apply_1')

    # Declined an offer
    create_application_choice(status: :with_declined_offer, phase: 'apply_1')

    # Withdrew an application
    create_application_choice(status: :withdrawn, phase: 'apply_2')

    # Application rejected
    create_application_choice(status: :with_rejection, phase: 'apply_1')
    create_application_choice(status: :with_rejection, phase: 'apply_2')

    # Unsubmitted applications are not considered
    create(:application_choice, status: :unsubmitted, application_form: create(:application_form, phase: 'apply_1'))

    expect(statistics).to eq({
      rows: [
        {
          'Status' => 'Recruited',
          'First application' => 1,
          'Apply again' => 0,
          'Total' => 1,
        },
        {
          'Status' => 'Conditions pending',
          'First application' => 2,
          'Apply again' => 0,
          'Total' => 2,
        },
        {
          'Status' => 'Received an offer but not responded',
          'First application' => 0,
          'Apply again' => 2,
          'Total' => 2,
        },
        {
          'Status' => 'Awaiting provider decisions',
          'First application' => 1,
          'Apply again' => 1,
          'Total' => 2,
        },
        {
          'Status' => 'Declined an offer',
          'First application' => 1,
          'Apply again' => 0,
          'Total' => 1,
        },
        {
          'Status' => 'Withdrew an application',
          'First application' => 0,
          'Apply again' => 1,
          'Total' => 1,
        },
        {
          'Status' => 'Application rejected',
          'First application' => 1,
          'Apply again' => 1,
          'Total' => 2,
        },
      ],
      column_totals: [6, 5, 11],
    })
  end

  def create_application_choice(status:, phase:)
    create(
      :application_choice,
      status,
      application_form: create(:application_form, phase: phase),
    )
  end
end
