require 'rails_helper'

RSpec.describe ReasonsForRejectionCountQuery do
  def reject_application(application_choice, reasons)
    ApplicationStateChange.new(application_choice).reject!
    application_choice.update!(
      structured_rejection_reasons: reasons,
      rejected_at: Time.zone.now,
    )
  end

  before do
    @application_choice1 = create(:application_choice, :awaiting_provider_decision)
    @application_choice2 = create(:application_choice, :awaiting_provider_decision)
    @application_choice3 = create(:application_choice, :awaiting_provider_decision)
    reject_application(
      @application_choice1,
      {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Mumbled',
        candidate_behaviour_what_to_improve: 'Speak clearly',
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement other],
        quality_of_application_personal_statement_what_to_improve: 'Was too personal',
        quality_of_application_other_details: 'Written in crayon',
        quality_of_application_other_what_to_improve: 'Write with a pen',
        qualifications_y_n: 'Yes',
        qualifications_which_qualifications: %w[no_maths_gcse],
        qualifications_other_details: 'You need maths',
        performance_at_interview_y_n: 'Yes',
        performance_at_interview_what_to_improve: 'Be on time',
      },
    )
    reject_application(
      @application_choice2,
      {
        qualifications_y_n: 'No',
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
      },
    )
    reject_application(
      @application_choice3,
      {
        candidate_behaviour_y_n: 'Yes',
        candidate_behaviour_what_did_the_candidate_do: %w[other],
        candidate_behaviour_other: 'Mumbled',
        candidate_behaviour_what_to_improve: 'Speak clearly',
        quality_of_application_y_n: 'Yes',
        quality_of_application_which_parts_needed_improvement: %w[personal_statement other],
      },
    )
    @application_choice3.update!(rejected_at: 2.months.ago)
  end

  describe '#reason_counts' do
    it 'returns correct values' do
      counts = described_class.new.reason_counts
      expect(counts[:candidate_behaviour_y_n]).to eq(
        described_class::Result.new(3, 2, {}),
      )
      expect(counts[:qualifications_y_n]).to eq(
        described_class::Result.new(1, 1, {}),
      )
    end
  end

  describe '#sub_reason_counts' do
    it 'returns correct values' do
      counts = described_class.new.sub_reason_counts
      expect(counts[:candidate_behaviour_y_n].sub_reasons[:other]).to eq(
        described_class::Result.new(3, 2, nil),
      )
      expect(counts[:quality_of_application_y_n].sub_reasons[:personal_statement]).to eq(
        described_class::Result.new(2, 1, nil),
      )
    end

    it 'includes zero values' do
      counts = described_class.new.sub_reason_counts
      expect(counts[:qualifications_y_n].sub_reasons.count).to be(5)
      expect(counts[:qualifications_y_n].sub_reasons[:no_english_gcse]).to eq(
        described_class::Result.new(0, 0, nil),
      )
    end
  end
end
