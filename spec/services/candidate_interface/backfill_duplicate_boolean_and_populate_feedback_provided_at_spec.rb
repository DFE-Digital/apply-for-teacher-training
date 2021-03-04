require 'rails_helper'

RSpec.describe CandidateInterface::BackfillDuplicateBooleanAndPopulateFeedbackProvidedAt do
  describe '#call' do
    around do |example|
      Timecop.freeze(Time.zone.local(2020, 6, 2, 12, 10, 0)) do
        example.run
      end
    end

    it 'sets duplicated references to true and updates to the latest feedback_provided_at' do
      feedback_provided_at = Time.zone.local(2020, 6, 1, 11, 10, 0)
      apply_1_application_form = create(:application_form, phase: :apply_1)
      apply_again_application_form = create(:application_form, phase: :apply_2)
      reference = create(
        :reference,
        :feedback_provided,
        feedback_provided_at: feedback_provided_at,
        application_form: apply_1_application_form,
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

      described_class.call

      expect(reference.reload.feedback_provided_at).to eq feedback_provided_at
      expect(duplicate_reference.reload.feedback_provided_at).to eq feedback_provided_at
      expect(duplicate_reference.reload.duplicate).to eq true
    end
  end
end
