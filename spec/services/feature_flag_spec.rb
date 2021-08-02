require 'rails_helper'

RSpec.describe FeatureFlag do
  describe '.activate' do
    it 'activates a feature' do
      expect { described_class.activate('pilot_open') }.to(
        change { described_class.active?('pilot_open') }.from(false).to(true),
      )
    end

    it 'records the change in the database' do
      feature = Feature.create_or_find_by(name: 'pilot_open')
      feature.update!(active: false)
      expect { described_class.activate('pilot_open') }.to(
        change { feature.reload.active }.from(false).to(true),
      )
    end
  end

  describe '.deactivate' do
    it 'deactivates a feature' do
      described_class.activate('pilot_open')
      expect { described_class.deactivate('pilot_open') }.to(
        change { described_class.active?('pilot_open') }.from(true).to(false),
      )
    end

    it 'records the change in the database' do
      feature = Feature.create_or_find_by(name: 'pilot_open')
      feature.update!(active: true)
      expect { described_class.deactivate('pilot_open') }.to(
        change { feature.reload.active }.from(true).to(false),
      )
    end
  end
end
