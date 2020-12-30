require 'rails_helper'

RSpec.describe WithdrawApplication do
  let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }

  describe '#save!' do
    it 'changes the state of the application_choice to "withdrawn"' do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to change { application_choice.status }.to('withdrawn')
    end

    it 'calls SetDeclineByDefault with the withdrawn application’s application_form' do
      decline_by_default = instance_double(SetDeclineByDefault, call: nil)
      allow(SetDeclineByDefault).to receive(:new).and_return(decline_by_default)

      WithdrawApplication.new(application_choice: application_choice).save!

      expect(SetDeclineByDefault).to have_received(:new).with(application_form: application_choice.application_form)
    end

    describe 'when provider_user notifications are on' do
      let(:provider_user) { create :provider_user, send_notifications: true, providers: [application_choice.provider] }

      it 'sends and tracks email notification to the provider user' do
        expect {
          described_class.new(application_choice: application_choice).save!
        }.to have_metrics_tracked(application_choice, 'notifications.on', provider_user, :application_withdrawn)
      end
    end

    describe 'when provider_user notifications are off' do
      let(:provider_user) { create :provider_user, send_notifications: false, providers: [application_choice.provider] }

      it 'tracks that an email notification was sent' do
        expect {
          described_class.new(application_choice: application_choice).save!
        }.to have_metrics_tracked(application_choice, 'notifications.off', provider_user, :application_withdrawn)
      end
    end

    describe 'retrieving a UCASMatch' do
      let(:candidate) { create(:candidate) }
      let(:ucas_match) { create(:ucas_match, candidate: candidate, action_taken: 'initial_emails_sent', matching_data: [match, match]) }
      let(:ucas_match_not_ready) { create(:ucas_match, candidate: candidate, matching_data: [match, match]) }
      let(:match) { { 'Scheme' => 'B', 'Course code' => course.code.to_s, 'Apply candidate ID' => candidate.id.to_s, 'Provider code' => course.provider.code.to_s } }
      let(:course) { application_choice.course_option.course }

      before do
        create(:application_form, candidate_id: candidate.id, application_choices: [application_choice])
      end

      it 'when there is a not ready to resolve it does nothing' do
        ucas_match_not_ready

        WithdrawApplication.new(application_choice: application_choice).save!
      end

      it 'when there is a match ready to resolve it resolves it' do
        ucas_match

        resolve_on_apply = instance_double(UCASMatches::ResolveOnApply, call: nil)
        allow(UCASMatches::ResolveOnApply).to receive(:new).and_return(resolve_on_apply)

        WithdrawApplication.new(application_choice: application_choice).save!

        expect(UCASMatches::ResolveOnApply).to have_received(:new)
      end
    end
  end
end
