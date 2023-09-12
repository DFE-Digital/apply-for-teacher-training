require 'rails_helper'

RSpec.describe Feature do
  describe 'auditing', :with_audited do
    it 'records an audit entry when creating a new Feature' do
      feature = create(:feature)
      expect(feature.audits.count).to eq 1
    end

    it 'records an audit entry when updating Feature#active' do
      feature = create(:feature)
      expect { feature.update(active: true) }.to change { feature.audits.count }.by(1)
    end
  end
end
