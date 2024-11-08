require 'rails_helper'

RSpec.describe DataMigrations::RemoveTdaFlag do
  context 'when the feature flags exist' do
    it 'removes both feature flags' do
      create(:feature, name: 'teacher_degree_apprenticeship')

      expect { described_class.new.change }.to change { Feature.count }.by(-1)
      expect(Feature.where(name: 'teacher_degree_apprenticeship')).to be_blank
    end
  end

  context 'when the feature flags have already been dropped' do
    it 'does nothing' do
      expect { described_class.new.change }.not_to(change { Feature.count })
    end
  end
end
