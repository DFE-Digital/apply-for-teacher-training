require 'rails_helper'

RSpec.describe StateChangeNotifier do
  let(:helpers) { Rails.application.routes.url_helpers }

  before do
    allow(SlackNotificationWorker).to receive(:perform_async)
  end

  describe '#call' do
    let(:candidate)           { create(:candidate) }
    let(:application_choice)  { create(:application_choice) }
    let(:applicant)           { application_choice.application_form.first_name }
    let(:provider_name)       { application_choice.course.provider.name }
    let(:application_form)    { application_choice.application_form }
    let(:application_form_id) { application_choice.application_form.id }
    let(:course_name)         { application_choice.course.name_and_code }

    describe ':change_an_offer' do
      before { described_class.call(:change_an_offer, application_choice: application_choice) }

      it 'mentions applicant\'s first name and provider name' do
        arg1 = ":love_letter: #{provider_name} has changed an offer for #{applicant}’s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end
  end

  describe '.sign_up' do
    let(:candidate_count) { 0 }

    before do
      fake_relation = instance_double('ActiveRecord::Relation', count: candidate_count)
      allow(Candidate).to receive(:where).and_return fake_relation
      described_class.sign_up(create(:candidate))
    end

    context 'every 100 candidate' do
      let(:candidate_count) { 200 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/sparkles.+200th candidate/, anything)
      end
    end

    context 'every 500th candidate' do
      let(:candidate_count) { 1000 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/ultrafastparrot.+1,000th candidate/, anything)
      end
    end

    context 'counts over 1000' do
      let(:candidate_count) { 1500 }

      it 'reports the sign up' do
        expect(SlackNotificationWorker).to have_received(:perform_async).with(/1,500th candidate/, anything)
      end
    end
  end
end
