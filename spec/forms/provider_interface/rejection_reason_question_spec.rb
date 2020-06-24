require 'rails_helper'

RSpec.describe ProviderInterface::RejectionReasonQuestion do
  describe '#answered_yes?' do
    it 'returns true if the question was answered yes' do
      rejection_reason_question = described_class.new(
        label: 'course_is_full',
        y_or_n: 'Y',
      )
      expect(rejection_reason_question.answered_yes?('course_is_full')).to eq(true)
    end

    it 'returns false if the question was answered no' do
      rejection_reason_question = described_class.new(
        label: 'course_is_full',
        y_or_n: 'N',
      )
      expect(rejection_reason_question.answered_yes?('course_is_full')).to eq(false)
    end
  end

  describe '#yes?' do
    it 'returns true if the y_or_n attribute is `Y`' do
      rejection_reason_question = described_class.new(y_or_n: 'Y')
      expect(rejection_reason_question.yes?).to eq(true)
    end

    it 'returns false if the y_or_n attribute is not `Y`' do
      rejection_reason_question = described_class.new(y_or_n: 'N')
      expect(rejection_reason_question.yes?).to eq(false)
    end
  end

  describe '#no?' do
    it 'returns true if the y_or_n attribute is not `Y`' do
      rejection_reason_question = described_class.new(
        y_or_n: 'N',
        answered: true,
      )
      expect(rejection_reason_question.no?).to eq(true)
    end

    it 'returns false if the y_or_n attribute is not `Y`' do
      rejection_reason_question = described_class.new(
        y_or_n: 'Y',
        answered: true,
      )
      expect(rejection_reason_question.no?).to eq(false)
    end
  end
end
