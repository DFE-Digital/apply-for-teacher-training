require 'rails_helper'

RSpec.describe CandidateInterface::BackfillDuplicateBooleanAndPopulateFeedbackProvidedAt do
  describe '#call' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 6, 2, 12, 10, 0)) do
        example.run
      end
    end

    it 'sets duplicated references to true and updates to the earliest feedback_provided_at' do
      feedback_provided_at = Time.zone.local(2020, 6, 1, 11, 10, 0)
      apply_1_application_form1 = create(:application_form, phase: :apply_1)
      apply1_application_form2 = create(:application_form, phase: :apply_1)
      apply_again_application_form = create(:application_form, phase: :apply_2, candidate: apply_1_application_form1.candidate)
      reference = create(
        :reference,
        :feedback_provided,
        feedback_provided_at: feedback_provided_at,
        application_form: apply_1_application_form1,
        created_at: 1.year.ago,
      )
      duplicate_reference = create(
        :reference,
        :feedback_provided,
        feedback_provided_at: nil,
        name: reference.name,
        email_address: reference.email_address,
        feedback: reference.feedback,
        application_form: apply_again_application_form,
      )

      duplicate_reference_with_different_candidate = create(
        :reference,
        :feedback_provided,
        feedback_provided_at: feedback_provided_at - 1.day,
        application_form: apply1_application_form2,
        name: reference.name,
        email_address: reference.email_address,
        feedback: reference.feedback,
        created_at: 1.year.ago,
      )

      described_class.call

      expect(reference.reload.feedback_provided_at).to eq feedback_provided_at
      expect(duplicate_reference.reload.feedback_provided_at).to eq feedback_provided_at
      expect(duplicate_reference.reload.duplicate).to eq true
      expect(duplicate_reference_with_different_candidate.feedback_provided_at).to eq feedback_provided_at - 1.day
      expect(duplicate_reference_with_different_candidate.reload.duplicate).to eq false
    end
  end
end
