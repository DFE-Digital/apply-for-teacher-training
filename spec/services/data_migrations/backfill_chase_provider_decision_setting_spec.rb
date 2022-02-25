require 'rails_helper'

RSpec.describe DataMigrations::BackfillChaseProviderDecisionSetting do
  it 'backfills chase provider decision columns' do
    application_received_on = create(:provider_user_notification_preferences, application_received: true)
    application_received_off = create(:provider_user_notification_preferences, application_received: false)

    described_class.new.change

    expect(application_received_on.reload.chase_provider_decision).to be(true)
    expect(application_received_off.reload.chase_provider_decision).to be(false)
  end
end
