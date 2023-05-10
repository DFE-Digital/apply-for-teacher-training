require 'rails_helper'

RSpec.describe WordCountValidator do
  maximum = 10

  before do
    stub_const('Validatable', Class.new).class_eval do
      include ActiveModel::Validations
      attr_accessor :some_words
      validates :some_words, word_count: { maximum: }
    end
  end

  let(:model) do
    Validatable.new.tap { |model| model.some_words = some_words_field }
  end

  let(:expected_errors) { ["Must be #{maximum} words or less"] }

  subject! do
    model.valid?
  end

  context 'with max valid number of words' do
    let(:some_words_field) { (%w[word] * maximum).join(' ') }

    it { is_expected.to be true }
  end

  context 'with no words' do
    let(:some_words_field) { '' }

    it { is_expected.to be true }
  end

  context 'with nil words' do
    let(:some_words_field) { nil }

    it { is_expected.to be true }
  end

  context 'with number of words exceeding the maximum by 1' do
    let(:some_words_field) { "#{(%w[word] * maximum).join(' ')} popped" }

    it { is_expected.to be false }

    it 'adds an error with details of maximum and count of words exceeding it' do
      expect(model.errors.details[:some_words]).to eql([{
        error: :too_many_words,
        maximum: maximum,
        count: 1,
      }])
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context 'with newlines' do
    let(:some_words_field) { "#{(%w[word] * maximum).join("\n")} popped" }

    it { is_expected.to be false }

    it 'adds an error' do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end

  context 'with non-words such as markdown' do
    let(:some_words_field) { "#{(%w[word] * maximum).join(' ')} *" }

    it { is_expected.to be false }

    it 'adds an error' do
      expect(model.errors[:some_words]).to match_array expected_errors
    end
  end
end
