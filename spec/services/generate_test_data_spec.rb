require 'rails_helper'

RSpec.describe GenerateTestData do
  describe '#generate' do
    it 'generates test data' do
      expect { GenerateTestData.new.generate(2) }
        .to change { Candidate.count }.by(2)
        .and change { ApplicationForm.count }.by(2)
        .and change { ApplicationChoice.count }.by_at_least(2)
    end
  end
end
