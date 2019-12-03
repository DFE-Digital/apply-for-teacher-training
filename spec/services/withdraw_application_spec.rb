require 'rails_helper'

RSpec.describe WithdrawApplication do
  describe '#save!' do
    it 'changes the state of the application_choice to "withdrawn"' do
      choice = create(:application_choice, status: :awaiting_provider_decision)

      WithdrawApplication.new(application_choice: choice).save!

      expect(choice.reload.status).to eq 'withdrawn'
    end

    it 'calls SetDeclineByDefault with the withdrawn application’s application_form' do
      withdrawing_application = create(:application_choice, status: :awaiting_provider_decision)
      allow(SetDeclineByDefault).to receive(:new).and_call_original

      WithdrawApplication.new(application_choice: withdrawing_application).save!

      expect(SetDeclineByDefault).to have_received(:new).with(application_form: withdrawing_application.application_form)
    end
  end
end
