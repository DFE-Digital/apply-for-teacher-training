require 'rails_helper'

RSpec.describe StateChangeNotifier do
  let(:helpers) { Rails.application.routes.url_helpers }

  describe '#call' do
    let(:candidate)           { create(:candidate) }
    let(:application_choice)  { create(:application_choice) }
    let(:applicant)           { application_choice.application_form.first_name }
    let(:provider_name)       { application_choice.course.provider.name }
    let(:application_form)    { application_choice.application_form }
    let(:application_form_id) { application_choice.application_form.id }
    let(:course_name)         { application_choice.course.name_and_code }

    before { allow(SlackNotificationWorker).to receive(:perform_async) }

    describe ':magic_link_sign_up' do
      before { StateChangeNotifier.call(:magic_link_sign_up, candidate: candidate) }

      it 'mentions the candidate\'s id' do
        arg1 = "New sign-up [candidate_id: #{candidate.id}]"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to support interface' do
        arg2 = helpers.support_interface_candidate_url(candidate)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':submit_application' do
      before { StateChangeNotifier.call(:submit_application, application_form: application_form) }

      it 'mentions applicant\'s first name' do
        arg1 = "#{applicant} has just submitted their application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':send_application_to_provider' do
      before { StateChangeNotifier.call(:send_application_to_provider, application_choice: application_choice) }

      it 'mentions applicant\'s first name and provider name' do
        arg1 = "#{applicant}'s application is ready to be reviewed by #{provider_name}"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':make_an_offer' do
      before { StateChangeNotifier.call(:make_an_offer, application_choice: application_choice) }

      it 'mentions applicant\s first name and provider name' do
        arg1 = "#{provider_name} has just made an offer to #{applicant}'s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':reject_application' do
      before { StateChangeNotifier.call(:reject_application, application_choice: application_choice) }

      it 'mentions applicant\s first name and provider name' do
        arg1 = "#{provider_name} has just rejected #{applicant}'s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':reject_application_by_default' do
      before { StateChangeNotifier.call(:reject_application_by_default, application_choice: application_choice) }

      it 'mentions applicant\s first name' do
        arg1 = "#{applicant}'s application has just been rejected by default"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':withdraw' do
      before { StateChangeNotifier.call(:withdraw, application_choice: application_choice) }

      it 'includes the applicant name and course identifier' do
        arg1 = ":runner: #{applicant} has withdrawn their application for #{course_name} at #{provider_name}"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end
  end
end
