require 'rails_helper'

RSpec.describe ProviderInterface::RejectionReasonsForm do
  describe '.questions' do
    let(:config_path) { Rails.root.join('config/rejection_reasons_questions.yml') }

    it 'loads and memoizes all questions from a config file' do
      allow(YAML).to receive(:load_file).with(config_path).and_return([:config])

      described_class.questions
      described_class.questions

      expect(YAML).to have_received(:load_file).at_most(:once).with(config_path)
    end
  end

  describe '#questions_for_current_step' do
    context 'when no questions have been answered' do
      subject(:rejection_reasons_form) { described_class.new }

      it 'returns the first set of questions' do
        expected_questions = described_class.questions.take(described_class::STEP_1_QUESTION_COUNT)
        expect(rejection_reasons_form.questions_for_current_step).to eq(expected_questions)
      end
    end

    context 'when the first set of questions have been answered and the last 2 answers were "No"' do
      let(:questions_attributes) do
        attr_hash = {}
        described_class::STEP_1_QUESTION_COUNT.times { |n| attr_hash["questions[#{n}]"] = { y_or_n: 'N', answered: true } }

        { questions_attributes: attr_hash }
      end

      subject(:rejection_reasons_form) { described_class.new(questions_attributes) }

      it 'returns the second set of questions' do
        expected_questions = described_class.questions.drop(described_class::STEP_1_QUESTION_COUNT)

        expect(rejection_reasons_form.questions_for_current_step).to eq(expected_questions)
      end
    end

    context 'when all questions have been answered' do
      let(:questions_attributes) do
        attr_hash = {}
        described_class.questions.size.times { |n| attr_hash["questions[#{n}]"] = { y_or_n: 'N', answered: true } }

        { questions_attributes: attr_hash }
      end

      subject(:rejection_reasons_form) { described_class.new(questions_attributes) }

      it 'returns an empty array' do
        expect(rejection_reasons_form.questions_for_current_step).to eq([])
      end
    end
  end
end
