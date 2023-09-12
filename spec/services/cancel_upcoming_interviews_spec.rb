require 'rails_helper'

RSpec.describe CancelUpcomingInterviews do
  let(:actor) { create(:provider_user) }
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
  let(:cancellation_reason) { Faker::Lorem.paragraph(sentence_count: 2) }
  let(:service) { described_class.new(actor:, application_choice:, cancellation_reason:) }

  context 'when an application has an interview scheduled today' do
    let!(:interview) { create(:interview, application_choice:, date_and_time: 1.hour.from_now) }

    it 'does not cancel the interview' do
      service.call!

      expect(interview.cancellation_reason).to be_nil
      expect(interview.cancelled_at).to be_nil
    end
  end

  context 'when an application has an interview scheduled yesterday' do
    let!(:interview) { create(:interview, application_choice:, date_and_time: 1.day.ago) }

    it 'does not cancel the interview' do
      service.call!

      expect(interview.cancellation_reason).to be_nil
      expect(interview.cancelled_at).to be_nil
    end
  end

  context 'when an application has interviews scheduled in the future' do
    let!(:first_interview) { create(:interview, application_choice:, date_and_time: 1.day.from_now) }
    let!(:second_interview) { create(:interview, application_choice:, date_and_time: 2.days.from_now) }
    let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_later: true) }

    before { allow(CandidateMailer).to receive(:interview_cancelled).and_return(mailer) }

    it 'cancels the interviews with the given reason' do
      service.call!

      expect(first_interview.reload.cancellation_reason).to eq(cancellation_reason)
      expect(first_interview.reload.cancelled_at).to be_within(1.second).of(Time.zone.now)
      expect(second_interview.reload.cancellation_reason).to eq(cancellation_reason)
      expect(second_interview.reload.cancelled_at).to be_within(1.second).of(Time.zone.now)
    end

    it 'emails the candidate about each interview cancellation' do
      service.call!

      expect(CandidateMailer).to have_received(:interview_cancelled).with(application_choice, first_interview, cancellation_reason)
      expect(CandidateMailer).to have_received(:interview_cancelled).with(application_choice, second_interview, cancellation_reason)
      expect(mailer).to have_received(:deliver_later).twice
    end

    it 'attributes the changes to the actor', :with_audited do
      service.call!

      expect(first_interview.audits.last.user).to eq(actor)
    end
  end

  context 'when an application has interviews scheduled in the future that have been cancelled' do
    let!(:interview) { create(:interview, :cancelled, application_choice:, date_and_time: 1.day.from_now) }

    it 'does not cancel the interview again' do
      expect { service.call! }.not_to change(interview, :cancelled_at)
    end
  end
end
