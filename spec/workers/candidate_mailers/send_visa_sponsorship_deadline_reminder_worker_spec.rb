require 'rails_helper'

module CandidateMailers
  RSpec.describe SendVisaSponsorshipDeadlineReminderWorker do
    describe '#perform' do
      it 'sends visa visa sponsorship deadline reminder email' do
        application_choice = create(:application_choice)
        mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
        allow(CandidateMailer).to(
          receive(:visa_sponsorship_deadline_reminder).and_return(mailer),
        )

        expect { described_class.new.perform([application_choice.id]) }.to change(ChaserSent, :count).from(0).to(1)

        chaser = application_choice.chasers_sent.last
        expect(chaser.chaser_type).to eq('visa_sponsorship_deadline')
        expect(chaser.course_id).to eq(application_choice.current_course.id)

        expect(mailer).to have_received(:deliver_later)
      end
    end
  end
end
