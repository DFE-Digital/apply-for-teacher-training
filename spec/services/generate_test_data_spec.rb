require 'rails_helper'

RSpec.describe GenerateTestData do
  describe '#generate' do
    it 'generates test data' do
      expect { GenerateTestData.new(2).generate }
        .to change { Candidate.count }.by(2)
        .and change { ApplicationForm.count }.by(2)
        .and change { ApplicationChoice.count }.by_at_least(2)
    end

    it 'assigns all application choices to a single provider' do
      GenerateTestData.new(2).generate
      ApplicationChoice.all.each do |application_choice|
        expect(application_choice.provider.code).to eq 'ABC'
      end
    end

    it 'assigns all application choices to the specified provider' do
      GenerateTestData.new(2, create(:provider, code: 'DEF')).generate
      ApplicationChoice.all.each do |application_choice|
        expect(application_choice.provider.code).to eq 'DEF'
      end
    end

    it 'assigns all application choices to the application_complete state' do
      GenerateTestData.new(2).generate
      ApplicationChoice.all.each do |application_choice|
        expect(application_choice.status).to eq 'application_complete'
      end
    end

    it 'works when duplicate course codes are generated' do
      provider = create(:provider, code: 'DEF')
      Faker::Config.random = Random.new(42)
      GenerateTestData.new(1, provider).generate
      Faker::Config.random = Random.new(42)
      GenerateTestData.new(1, provider).generate
    end
  end
end
