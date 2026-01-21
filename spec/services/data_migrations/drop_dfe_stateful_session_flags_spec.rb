require 'rails_helper'
# rubocop:disable RSpec/SpecFilePathFormat

RSpec.describe DataMigrations::DropDfEStatefulSessionFlags do
  describe '#change' do
    it 'runs the migration' do
      create(:feature, name: 'separate_dsi_controllers')
      create(:feature, name: 'dsi_stateful_session')

      expect { described_class.new.change }.to change { Feature.count }.by(-2)
      expect(Feature.where(name: 'separate_dsi_controllers')).to be_blank
      expect(Feature.where(name: 'dsi_stateful_session')).to be_blank
    end

    context 'when the feature flag has already been dropped' do
      it 'does nothing' do
        expect { described_class.new.change }.not_to(change { Feature.count })
      end
    end
  end
end

# rubocop:enable RSpec/SpecFilePathFormat
