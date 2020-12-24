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

    describe ':make_an_offer' do
      before { StateChangeNotifier.call(:make_an_offer, application_choice: application_choice) }

      it 'mentions applicant\'s first name and provider name' do
        arg1 = ":love_letter: #{provider_name} has made an offer to #{applicant}’s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

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

    describe ':reject_application' do
      before { StateChangeNotifier.call(:reject_application, application_choice: application_choice) }

      it 'mentions applicant\'s first name and provider name' do
        arg1 = ":broken_heart: #{provider_name} has rejected #{applicant}’s application"
        expect(SlackNotificationWorker).to have_received(:perform_async).with(arg1, anything)
      end

      it 'links the notification to the relevant support_interface application_form' do
        arg2 = helpers.support_interface_application_form_url(application_form_id)
        expect(SlackNotificationWorker).to have_received(:perform_async).with(anything, arg2)
      end
    end

    describe ':reject_application_by_default' do
      before { StateChangeNotifier.call(:reject_application_by_default, application_choice: application_choice) }

      it 'mentions applicant\'s first name' do
        arg1 = ":broken_heart: #{applicant}’s application to #{provider_name} has been rejected by default"
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

    describe ':withdraw_offer' do
      before { StateChangeNotifier.call(:withdraw_offer, application_choice: application_choice) }

      it 'includes the applicant name and course identifier' do
        arg1 = ":no_good: #{provider_name} has withdrawn #{applicant}’s offer"
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

  describe '.accept_offer' do
    let(:application_form) { create(:application_form, first_name: 'Leah') }
    let(:provider) { create(:provider, name: 'UCL') }

    let(:english) { create(:course, provider: provider, name: 'English', code: 'EEE') }
    let(:french) { create(:course, provider: provider, name: 'French', code: 'FFF') }
    let(:maths) { create(:course, provider: provider, name: 'Maths', code: 'MMM') }

    let(:accepted) do
      create(:application_choice,
             application_form: application_form,
             course_option: create(:course_option, course: english))
    end
    let(:declined) { [] }
    let(:withdrawn) { [] }

    before { StateChangeNotifier.accept_offer(accepted: accepted, declined: declined, withdrawn: withdrawn) }

    context 'when this is the only application choice' do
      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE)'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end

    context 'when there is another offer that’s been declined' do
      let(:declined) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: french))]
      end

      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE) and declined UCL’s offer for French (FFF)'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end

    context 'when there is another offer that’s been withdrawn' do
      let(:withdrawn) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: french))]
      end

      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE) and withdrawn their application for French (FFF) at UCL'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end

    context 'when there’s another offer withdrawn and another declined' do
      let(:withdrawn) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: french))]
      end

      let(:declined) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: maths))]
      end

      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE), withdrawn their application for French (FFF) at UCL, and declined UCL’s offer for Maths (MMM)'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end

    context 'when there are two offers withdrawn' do
      let(:withdrawn) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: french)),
         create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: maths))]
      end

      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE) and withdrawn their applications for French (FFF) at UCL and Maths (MMM) at UCL'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end

    context 'when there are two offers declined' do
      let(:declined) do
        [create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: french)),
         create(:application_choice,
                application_form: application_form,
                course_option: create(:course_option, course: maths))]
      end

      it 'shows the correct message' do
        expected_message = ':handshake: Leah has accepted UCL’s offer for English (EEE) and declined UCL’s offer for French (FFF) and UCL’s offer for Maths (MMM)'
        expect(SlackNotificationWorker).to have_received(:perform_async).with(expected_message, anything)
      end
    end
  end
end
