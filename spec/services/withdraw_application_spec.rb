require 'rails_helper'

RSpec.describe WithdrawApplication do
  describe '#save!' do
    it 'changes the state of the application_choice to "withdrawn"' do
      choice = create(:application_choice, status: :awaiting_provider_decision)

      WithdrawApplication.new(application_choice: choice).save!

      expect(choice.reload.status).to eq 'withdrawn'
    end
  end
end
