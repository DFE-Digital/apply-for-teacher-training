require 'rails_helper'

RSpec.describe SupportInterface::ConditionsForm do
  describe '.build_from_application_choice' do
    it 'handles a missing offer value' do
      application_choice = build(:application_choice, offer: nil)
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_conditions).to eq(['', '', '', ''])
    end

    it 'handles an empty set of conditions' do
      application_choice = build(:application_choice, offer: { 'conditions' => [] })
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq([])
      expect(form.further_conditions).to eq(['', '', '', ''])
    end

    it 'reads standard and further conditions' do
      application_choice = build(
        :application_choice,
        offer: { 'conditions' => ['Fitness to train to teach check', 'Get a haircut'] },
      )
      form = described_class.build_from_application_choice(application_choice)
      expect(form.standard_conditions).to eq(['Fitness to train to teach check'])
      expect(form.further_conditions).to eq(['Get a haircut', '', '', ''])
    end
  end
end
