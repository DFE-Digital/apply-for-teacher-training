require 'rails_helper'

RSpec.describe DataMigrations::DropGroupedInviteEmailFeatureFlag do
  context 'when the feature flag exists' do
    it 'removes the feature flag' do
      Feature.find_or_create_by(name: 'grouped_invite_email')

      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'grouped_invite_email')).to be_blank
    end
  end

  context 'when the feature flag has already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
