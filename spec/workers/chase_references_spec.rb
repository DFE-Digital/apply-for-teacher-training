require 'rails_helper'

RSpec.describe ChaseReferences, sidekiq: true do
  describe '#perform' do
    let(:deliverer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let!(:application_form) { create(:application_form, :minimum_info) }
    let!(:reference) { create(:reference, :feedback_requested, application_form: application_form) }

    around do |example|
      Timecop.travel(Time.zone.local(2022, 4, 1)) { example.run }
    end

    it 'chase references and notify candidates' do
      allow(CandidateMailer).to receive(:chase_reference).and_return(deliverer)
      allow(CandidateMailer).to receive(:new_referee_request).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chaser_email).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chase_again_email).and_return(deliverer)
      allow(CandidateMailer).to receive(:chase_reference_again).and_return(deliverer)

      Timecop.travel(8.days.from_now) do
        described_class.new.perform
      end

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference).exactly(1).times
      expect(CandidateMailer).not_to have_received(:chase_reference)

      Timecop.travel(10.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:chase_reference).with(reference).exactly(1).times

      Timecop.travel(15.days.from_now) do
        described_class.new.perform
      end

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference).exactly(2).times

      Timecop.travel(17.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:new_referee_request).with(reference, reason: :not_responded).exactly(1).times

      Timecop.travel(29.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).to have_received(:reference_request_chase_again_email).with(reference)
      expect(CandidateMailer).not_to have_received(:chase_reference_again)

      Timecop.travel(31.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:chase_reference_again).with(reference)
    end

    it 'chase references only once on each chase' do
      Timecop.travel(8.days.from_now) do
        described_class.new.perform
      end

      expect(ActionMailer::Base.deliveries.count).to be 1

      Timecop.travel(10.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 2

      Timecop.travel(15.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 3

      Timecop.travel(17.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 4

      Timecop.travel(29.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 5

      Timecop.travel(31.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 6
    end

    it 'do not send email again for old references chasers' do
      allow(CandidateMailer).to receive(:chase_reference).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chaser_email).and_return(deliverer)
      allow(RefereeMailer).to receive(:reference_request_chase_again_email).and_return(deliverer)
      allow(CandidateMailer).to receive(:new_referee_request).and_return(deliverer)
      allow(CandidateMailer).to receive(:chase_reference_again).and_return(deliverer)
      create(:chaser_sent, chased: reference, chaser_type: :reference_request)

      Timecop.travel(8.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)
      expect(CandidateMailer).not_to have_received(:chase_reference)

      Timecop.travel(10.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)
      expect(CandidateMailer).not_to have_received(:chase_reference)

      create(:chaser_sent, chased: reference, chaser_type: :reminder_reference_nudge)
      Timecop.travel(15.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)

      create(:chaser_sent, chased: reference, chaser_type: :reference_replacement)
      Timecop.travel(17.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).not_to have_received(:new_referee_request)

      create(:chaser_sent, chased: reference, chaser_type: :follow_up_missing_references)
      Timecop.travel(31.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chase_again_email)
      expect(CandidateMailer).not_to have_received(:chase_reference_again)
    end
  end
end
