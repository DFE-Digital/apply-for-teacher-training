require 'rails_helper'

RSpec.describe MarkInactiveApplication do
  subject(:mark_inactive_application) { described_class.new(application_choice:) }

  describe '#call' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

    it 'changes to inactive state' do
      expect { mark_inactive_application.call }.to change(application_choice, :status).from('awaiting_provider_decision').to('inactive')
    end

    it 'updates inactive at field', time: Time.zone.local(2023, 11, 10) do
      expect { mark_inactive_application.call }.to change(application_choice, :inactive_at).from(nil).to(Time.zone.local(2023, 11, 10))
    end
  end
end
