require 'rails_helper'

RSpec.describe StateChangeNotifier do
  let(:helpers) { Rails.application.routes.url_helpers }

  before { allow(SlackNotificationWorker).to receive(:perform_async) }

  describe '#call' do
    let(:candidate)           { create(:candidate) }
    let(:application_choice)  { create(:application_choice) }
    let(:applicant)           { application_choice.application_form.first_name }
    let(:provider_name)       { application_choice.course.provider.name }
    let(:application_form)    { application_choice.application_form }
    let(:application_form_id) { application_choice.application_form.id }
    let(:course_name)         { application_choice.course.name_and_code }

    describe ':change_an_offer' do
      before { StateChangeNotifier.call(:change_an_offer, application_choice: application_choice) }

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
      StateChangeNotifier.sign_up(create(:candidate))
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

  describe '.application_outcome_notification' do
    let(:application_form) { build(:completed_application_form) }
    let(:applicant) { application_form.first_name }
    let(:provider_name) { application_choice.provider.name }
    let(:rejected_choice) { create(:application_choice, :with_rejection, application_form: application_form) }
    let(:declined_choice) { create(:application_choice, :with_declined_offer, application_form: application_form) }
    let(:withdrawn_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

    context ':rejected' do
      let(:application_choice) { create(:application_choice, :with_rejection, application_form: application_form) }

      it 'all applications are rejected' do
        rejected_choice

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart: #{applicant}'s application was rejected by #{provider_name} and #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined' do
        declined_choice

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart:.+#{applicant} previously declined offers from #{declined_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn' do
        withdrawn_choice

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart:.+#{applicant} previously withdrew from #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined and withdrawn' do
        declined_choice
        withdrawn_choice

        StateChangeNotifier.new(:rejected, application_choice).application_outcome_notification

        message = /:broken_heart:.+#{applicant} previously declined offers from #{declined_choice.provider.name} and withdrew from #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':declined' do
      let(:application_choice) { create(:application_choice, :declined, application_form: application_form) }

      it 'all declined' do
        declined_choice

        StateChangeNotifier.new(:declined, application_choice).application_outcome_notification

        message = /:no_good: #{applicant} has declined #{provider_name} and #{declined_choice.provider.name} offer./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been rejected' do
        rejected_choice

        StateChangeNotifier.new(:declined, application_choice).application_outcome_notification

        message = /:no_good:.+ #{applicant} previously was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn' do
        withdrawn_choice

        StateChangeNotifier.new(:declined, application_choice).application_outcome_notification

        message = /:no_good:.+#{applicant} previously withdrew from #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn and declined' do
        withdrawn_choice
        rejected_choice

        StateChangeNotifier.new(:declined, application_choice).application_outcome_notification

        message = /:no_good:.+#{applicant} previously withdrew from #{withdrawn_choice.provider.name} and was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':withdrawn' do
      let(:application_choice) { create(:application_choice, :withdrawn, application_form: application_form) }

      it 'all withdrawn' do
        withdrawn_choice

        StateChangeNotifier.new(:withdrawn, application_choice).application_outcome_notification

        message = /:runner: #{applicant} has withdrawn their remaining applications from #{provider_name} and #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been rejected' do
        rejected_choice

        StateChangeNotifier.new(:withdrawn, application_choice).application_outcome_notification

        message = /:runner:.+ #{applicant} previously was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined' do
        declined_choice

        StateChangeNotifier.new(:withdrawn, application_choice).application_outcome_notification

        message = /:runner:.+#{applicant} previously declined offers from #{declined_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been rejected and declined' do
        declined_choice
        rejected_choice

        StateChangeNotifier.new(:withdrawn, application_choice).application_outcome_notification

        message = /:runner:.+#{applicant} previously declined offers from #{declined_choice.provider.name} and was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end

    context ':recruited' do
      let(:application_choice) { create(:application_choice, :recruited, application_form: application_form) }

      it 'and no other applications' do
        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake: #{applicant} has been recruited to #{provider_name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been rejected' do
        rejected_choice

        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake:.+#{applicant} previously was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined' do
        declined_choice

        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake:.+#{applicant} previously declined offers from #{declined_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been withdrawn' do
        withdrawn_choice

        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake:.+#{applicant} previously withdrew from #{withdrawn_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end

      it 'other applications have been declined, rejected and withdrawn' do
        withdrawn_choice
        declined_choice
        rejected_choice

        StateChangeNotifier.new(:recruited, application_choice).application_outcome_notification

        message = /:handshake:.+#{applicant} previously declined offers from #{declined_choice.provider.name}, withdrew from #{withdrawn_choice.provider.name}, and was rejected by #{rejected_choice.provider.name}./
        expect(SlackNotificationWorker).to have_received(:perform_async).with(message, anything)
      end
    end
  end
end
