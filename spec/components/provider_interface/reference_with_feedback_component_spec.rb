require 'rails_helper'

RSpec.describe ProviderInterface::ReferenceWithFeedbackComponent do
  describe '#rows' do
    let(:reference) { build(:reference, feedback: 'A valuable unit of work') }

    subject(:component) { described_class.new(reference: reference) }

    it 'contains a name row' do
      row = component.rows.first
      expect(row[:key]).to eq('Name')
      expect(row[:value]).to eq(reference.name)
    end

    it 'contains an email address row' do
      row = component.rows.second
      expect(row[:key]).to eq('Email address')
      expect(row[:value]).to eq(reference.email_address)
    end

    it 'contains a relationship row' do
      row = component.rows.third
      expect(row[:key]).to eq('Relationship between candidate and referee')
      expect(row[:value]).to eq(reference.relationship)
    end

    it 'contains a confirmation row' do
      expect(component.rows.fourth[:key]).to eq('Relationship confirmed by referee?')
    end

    it 'affirms the referee relationship when uncorrected' do
      expect(component.rows.fourth[:value]).to eq('Yes')
    end

    it 'contains a correction as the row value when corrected' do
      reference.relationship_correction = 'This is not correct'
      expect(component.rows.fourth[:value]).to eq('This is not correct')
    end

    it 'contains a feedback row' do
      row = component.rows.last
      expect(row[:key]).to eq('Reference')
      expect(row[:value]).to eq(reference.feedback)
    end
  end
end
