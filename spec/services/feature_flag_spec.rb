require 'rails_helper'

RSpec.describe FeatureFlag do
  describe '.activate' do
    it 'activates a feature' do
      expect { described_class.activate('dfe_sign_in_fallback') }.to(
        change { described_class.active?('dfe_sign_in_fallback') }.from(false).to(true),
      )
    end

    it 'records the change in the database' do
      feature = Feature.create_or_find_by(name: 'dfe_sign_in_fallback')
      feature.update!(active: false)
      expect { described_class.activate('dfe_sign_in_fallback') }.to(
        change { feature.reload.active }.from(false).to(true),
      )
    end
  end

  describe '.deactivate' do
    it 'deactivates a feature' do
      # To avoid flakey tests where activation/deactivation happens at the same time
      Timecop.travel(5.minutes.ago) { described_class.activate('dfe_sign_in_fallback') }
      expect { described_class.deactivate('dfe_sign_in_fallback') }.to(
        change { described_class.active?('dfe_sign_in_fallback') }.from(true).to(false),
      )
    end

    it 'records the change in the database' do
      feature = Feature.create_or_find_by(name: 'dfe_sign_in_fallback')
      feature.update!(active: true)
      expect { described_class.deactivate('dfe_sign_in_fallback') }.to(
        change { feature.reload.active }.from(true).to(false),
      )
    end
  end
end
