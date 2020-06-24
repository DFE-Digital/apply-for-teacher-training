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

  describe '#all_step_1_answers_no?' do
    let(:attr_hash) { {} }
    let(:questions_attributes) { { questions_attributes: attr_hash } }

    subject(:rejection_reasons_form) { described_class.new(questions_attributes) }

    it 'returns true if all step 1 questions were answered no' do
      described_class::STEP_1_QUESTION_COUNT.times { |n| attr_hash["questions[#{n}]"] = { y_or_n: 'N', answered: true } }

      expect(rejection_reasons_form.all_step_1_answers_no?).to eq(true)
    end

    it 'returns false if not all step 1 questions were answered no' do
      described_class::STEP_1_QUESTION_COUNT.times { |n| attr_hash["questions[#{n}]"] = { y_or_n: 'Y', answered: true } }

      expect(rejection_reasons_form.all_step_1_answers_no?).to eq(false)
    end

    it 'returns false if there are no answered questions' do
      expect(rejection_reasons_form.all_step_1_answers_no?).to eq(false)
    end
  end

  describe '#answered_yes_to_question?' do
    let(:attr_hash) { {} }
    let(:question_key) { 'future_applications' }
    let(:questions_attributes) { { questions_attributes: attr_hash } }

    subject(:rejection_reasons_form) { described_class.new(questions_attributes) }

    it 'returns true if question was answered yes' do
      attr_hash['questions[9]'] = {
        label: 'rejection_reasons.questions.future_applications.label',
        y_or_n: 'Y',
        answered: true,
      }

      expect(rejection_reasons_form.answered_yes_to_question?(question_key)).to eq(true)
    end

    it 'returns false if question was answered no' do
      attr_hash['questions[9]'] = {
        label: 'rejection_reasons.questions.future_applications.label',
        y_or_n: 'N',
        answered: true,
      }

      expect(rejection_reasons_form.answered_yes_to_question?(question_key)).to eq(false)
    end
  end

  describe '#last_2_answers_no?' do
    it 'returns true if last 2 questions were answered no' do
      rejection_reasons_form = described_class.new(
        questions_attributes:
        {
          'questions[0]':
            {
              label: 'questions.course_is_full',
              y_or_n: 'Y',
              answered: true,
            },
          'questions[1]': {
            label: 'questions.concerns_about_honesty_and_professionalis',
            y_or_n: 'N',
            answered: true,
          },
          'questions[2]': {
            label: 'questions.safeguarding',
            y_or_n: 'N',
            answered: true,
          },
        },
      )

      expect(rejection_reasons_form.last_2_answers_no?).to eq(true)
    end

    it 'returns false if one of last 2 questions was answered no' do
      rejection_reasons_form = described_class.new(
        questions_attributes:
        {
          'questions[0]':
            {
              label: 'questions.course_is_full',
              y_or_n: 'Y',
              answered: true,
            },
          'questions[1]': {
            label: 'questions.concerns_about_honesty_and_professionalis',
            y_or_n: 'Y',
            answered: true,
          },
          'questions[2]': {
            label: 'questions.safeguarding',
            y_or_n: 'N',
            answered: true,
          },
        },
      )

      expect(rejection_reasons_form.last_2_answers_no?).to eq(false)
    end

    it 'returns false if last 2 questions were answered yes' do
      rejection_reasons_form = described_class.new(
        questions_attributes:
        {
          'questions[0]':
            {
              label: 'questions.course_is_full',
              y_or_n: 'Y',
              answered: true,
            },
          'questions[1]': {
            label: 'questions.concerns_about_honesty_and_professionalis',
            y_or_n: 'Y',
            answered: true,
          },
          'questions[2]': {
            label: 'questions.safeguarding',
            y_or_n: 'Y',
            answered: true,
          },
        },
      )

      expect(rejection_reasons_form.last_2_answers_no?).to eq(false)
    end
  end
end
