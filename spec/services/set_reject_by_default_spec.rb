require 'rails_helper'

RSpec.describe SetRejectByDefault do
  describe '#call' do
    it 'does not update dates when nothing changes', with_audited: true do
      application_choice = create(:application_choice, sent_to_provider_at: Time.zone.now)

      expect { call_service(application_choice) }.to change { Audited::Audit.count }.by(1)
      expect { call_service(application_choice) }.to change { Audited::Audit.count }.by(0)
    end
  end

  def call_service(application_choice)
    SetRejectByDefault.new(application_choice).call
  end
end
