require 'rails_helper'

RSpec.describe ChaseReferences, :sidekiq do
  describe '#perform', time: Time.zone.local(2022, 4, 1) do
    let(:deliverer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }
    let!(:application_form) { create(:application_form, :with_accepted_offer) }
    let!(:reference) { create(:reference, :feedback_requested, application_form: application_form) }

    it 'chase references and notify candidates' do
      allow(CandidateMailer).to receive_messages(chase_reference: deliverer, new_referee_request: deliverer, chase_reference_again: deliverer)
      allow(RefereeMailer).to receive_messages(reference_request_chaser_email: deliverer, reference_request_chase_again_email: deliverer)

      travel_temporarily_to(8.days.from_now) do
        described_class.new.perform
      end

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference).exactly(1).times
      expect(CandidateMailer).not_to have_received(:chase_reference)

      travel_temporarily_to(10.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:chase_reference).with(reference).exactly(1).times

      travel_temporarily_to(15.days.from_now) do
        described_class.new.perform
      end

      expect(RefereeMailer).to have_received(:reference_request_chaser_email).with(application_form, reference).exactly(2).times

      travel_temporarily_to(17.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:new_referee_request).with(reference, reason: :not_responded).exactly(1).times

      travel_temporarily_to(29.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).to have_received(:reference_request_chase_again_email).with(reference)
      expect(CandidateMailer).not_to have_received(:chase_reference_again)

      travel_temporarily_to(31.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).to have_received(:chase_reference_again).with(reference)
    end

    it 'chase references only once on each chase' do
      travel_temporarily_to(8.days.from_now) do
        described_class.new.perform
      end

      expect(ActionMailer::Base.deliveries.count).to be 1

      travel_temporarily_to(10.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 2

      travel_temporarily_to(15.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 3

      travel_temporarily_to(17.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 4

      travel_temporarily_to(29.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 5

      travel_temporarily_to(31.days.from_now) do
        described_class.new.perform
      end
      expect(ActionMailer::Base.deliveries.count).to be 6
    end

    it 'do not send email again for old references chasers' do
      allow(CandidateMailer).to receive_messages(chase_reference: deliverer, new_referee_request: deliverer, chase_reference_again: deliverer)
      allow(RefereeMailer).to receive_messages(reference_request_chaser_email: deliverer, reference_request_chase_again_email: deliverer)
      create(:chaser_sent, chased: reference, chaser_type: :reference_request)

      travel_temporarily_to(8.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)
      expect(CandidateMailer).not_to have_received(:chase_reference)

      travel_temporarily_to(10.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)
      expect(CandidateMailer).not_to have_received(:chase_reference)

      create(:chaser_sent, chased: reference, chaser_type: :reminder_reference_nudge)
      travel_temporarily_to(15.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chaser_email)

      create(:chaser_sent, chased: reference, chaser_type: :reference_replacement)
      travel_temporarily_to(17.days.from_now) do
        described_class.new.perform
      end
      expect(CandidateMailer).not_to have_received(:new_referee_request)

      create(:chaser_sent, chased: reference, chaser_type: :follow_up_missing_references)
      travel_temporarily_to(31.days.from_now) do
        described_class.new.perform
      end
      expect(RefereeMailer).not_to have_received(:reference_request_chase_again_email)
      expect(CandidateMailer).not_to have_received(:chase_reference_again)
    end
  end
end
