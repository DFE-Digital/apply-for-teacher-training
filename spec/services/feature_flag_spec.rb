require 'rails_helper'

RSpec.describe FeatureFlag do
  describe '.activate' do
    it 'activates a feature' do
      expect { FeatureFlag.activate('pilot_open') }.to(
        change { FeatureFlag.active?('pilot_open') }.from(false).to(true),
      )
    end
  end

  describe '.deactivate' do
    it 'deactivates a feature' do
      FeatureFlag.activate('pilot_open')
      expect { FeatureFlag.deactivate('pilot_open') }.to(
        change { FeatureFlag.active?('pilot_open') }.from(true).to(false),
      )
    end
  end
end
