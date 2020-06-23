require 'rails_helper'

RSpec.describe ProviderInterface::RejectionReasonsComponent do
  describe '#renderable_reasons' do
    let(:rejection_reasons) do
      [
        ProviderInterface::RejectionReasonQuestion.new(label: 'what_did_they_do', y_or_n: 'Y'),
        ProviderInterface::RejectionReasonQuestion.new(label: 'alternative_rejection_reasons', y_or_n: 'Y'),
        ProviderInterface::RejectionReasonQuestion.new(label: 'future_applications', y_or_n: 'Y'),
        ProviderInterface::RejectionReasonQuestion.new(label: 'something_something', y_or_n: 'N'),
      ]
    end

    subject(:component) { described_class.new(rejection_reasons: rejection_reasons) }

    it 'filters questions' do
      expect(component.renderable_reasons.size).to eq(2)
    end

    it 'orders questions' do
      expect(component.renderable_reasons.map(&:label)).to eq(%w[alternative_rejection_reasons what_did_they_do])
    end
  end

  describe '#answered_yes_to_question?' do
    let(:rejection_reasons) do
      [
        ProviderInterface::RejectionReasonQuestion.new(label: 'aa', y_or_n: 'Y'),
        ProviderInterface::RejectionReasonQuestion.new(label: 'bb', y_or_n: 'N'),
      ]
    end

    subject(:component) { described_class.new(rejection_reasons: rejection_reasons) }

    it 'is true for questions answered yes' do
      expect(component.answered_yes_to_question?('aa')).to be true
    end

    it 'is false for questions answered no' do
      expect(component.answered_yes_to_question?('bb')).to be false
    end
  end
end
