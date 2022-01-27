require 'rails_helper'

RSpec.describe DataMigrations::ResolveAllFraudulentDuplicateMatches do
  before do
    @fraud_match = create(:fraud_match, fraudulent: true, resolved: false)
  end

  it 'marks all fraudulent matches as resolved' do
    described_class.new.change
    expect(@fraud_match.reload).to be_resolved
  end
end
