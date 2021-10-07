require 'rails_helper'

RSpec.describe ChaseReferences do
  describe '#perform' do
    around do |example|
      Timecop.travel(after_apply_2_deadline) { example.run }
    end

    before do
      deliverer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(CandidateMailer).to receive(:chase_reference).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chaser_email).and_return(deliverer)
      allow(SendNewRefereeRequestEmail).to receive(:call).and_return true
      allow(CandidateMailer).to receive(:chase_reference_again).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chase_again_email).and_return(deliverer)
    end

    it 'only chases the newest references after an application has been carried over' do
      application_form = create(:application_form, :minimum_info)
      previous_reference = create(:reference, :feedback_requested, application_form: application_form)
      CarryOverApplication.new(application_form).call

      carried_over_reference = ApplicationForm.last.application_references.first

      Timecop.travel(8.days.from_now) do
        described_class.new.perform
      end

      expect(CandidateMailer).to have_received(:chase_reference).with(carried_over_reference).exactly(1).times
      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(carried_over_reference.application_form, carried_over_reference).exactly(1).times
      expect(CandidateMailer).not_to have_received(:chase_reference).with(previous_reference)
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email).with(previous_reference.application_form, previous_reference)

      Timecop.travel(15.days.from_now) do
        described_class.new.perform
      end

      expect(SendNewRefereeRequestEmail).to have_received(:call).with({ reference: carried_over_reference, reason: :not_responded }).exactly(1).times
      expect(SendNewRefereeRequestEmail).not_to have_received(:call).with({ reference: previous_reference, reason: :not_responded })

      Timecop.travel(29.days.from_now) do
        described_class.new.perform
      end

      expect(CandidateMailer).to have_received(:chase_reference_again).with(carried_over_reference).exactly(1).times
      expect(RefereeMailer).to have_received(:reference_request_chase_again_email).with(carried_over_reference).exactly(1).times
      expect(CandidateMailer).not_to have_received(:chase_reference_again).with(previous_reference)
      expect(RefereeMailer).not_to have_received(:reference_request_chase_again_email).with(previous_reference)
    end
  end
end
