require 'rails_helper'

RSpec.describe GenerateTestData do
  describe '#generate' do
    it 'generates test data' do
      expect { GenerateTestData.new.generate(2) }
        .to change { Candidate.count }.by(2)
        .and change { ApplicationForm.count }.by(2)
        .and change { ApplicationChoice.count }.by_at_least(2)
    end

    it 'assigns all application choices to a single provider' do
      GenerateTestData.new.generate(2)
      ApplicationChoice.all.each do |application_choice|
        expect(application_choice.provider.code).to eq 'ABC'
      end
    end
  end
end
