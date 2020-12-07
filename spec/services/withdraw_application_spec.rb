require 'rails_helper'

RSpec.describe WithdrawApplication do
  describe '#save!' do
    it 'changes the state of the application_choice to "withdrawn"' do
      choice = create(:application_choice, status: :awaiting_provider_decision)

      WithdrawApplication.new(application_choice: choice).save!

      expect(choice.reload.status).to eq 'withdrawn'
    end

    it 'calls SetDeclineByDefault with the withdrawn application’s application_form' do
      decline_by_default = instance_double(SetDeclineByDefault, call: nil)
      withdrawing_application = create(:application_choice, status: :awaiting_provider_decision)
      allow(SetDeclineByDefault).to receive(:new).and_return(decline_by_default)

      WithdrawApplication.new(application_choice: withdrawing_application).save!

      expect(SetDeclineByDefault).to have_received(:new).with(application_form: withdrawing_application.application_form)
    end

    describe 'retrieving a UCASMatch' do
      let(:candidate) { create(:candidate) }
      let(:ucas_match) { create(:ucas_match, candidate: candidate, action_taken: 'initial_emails_sent', matching_data: [ucas_matching_data, apply_matching_data]) }
      let(:ucas_match_not_ready) { create(:ucas_match, candidate: candidate, matching_data: [ucas_matching_data, apply_matching_data]) }
      let(:ucas_matching_data) { { 'Scheme' => 'B', 'Course code' => course.code.to_s, 'Apply candidate ID' => candidate.id.to_s, 'Provider code' => course.provider.code.to_s } }
      let(:apply_matching_data) { { 'Scheme' => 'B', 'Course code' => course.code.to_s, 'Apply candidate ID' => candidate.id.to_s, 'Provider code' => course.provider.code.to_s } }
      let(:application_choice) { create(:application_choice, status: :awaiting_provider_decision) }
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
