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

    context 'referee relationship confirmation' do
      it 'contains a confirmation row' do
        expect(component.rows.fourth[:key]).to eq('Relationship confirmed by referee?')
      end

      it 'affirms the referee relationship when uncorrected' do
        expect(component.rows.fourth[:value]).to eq('Yes')
      end

      it 'contains a correction as the row value when corrected' do
        reference.relationship_correction = 'This is not correct'

        expect(component.rows.fourth[:value]).to eq('No')

        correction_row = component.rows.fifth

        expect(correction_row[:key]).to eq('Relationship amended by referee')
        expect(correction_row[:value]).to eq('This is not correct')
      end
    end

    context 'safeguarding' do
      it 'contains a safeguarding row' do
        expect(component.rows.fifth[:key]).to eq(
          'Does the referee know of any reason why this candidate should not work with children?',
        )
      end

      it 'affirms safeguarding when no safeguarding concerns are present' do
        expect(component.rows.fifth[:value]).to eq('No')
      end

      it 'contains safeguarding concerns where present' do
        reference.safeguarding_concerns = 'Is a big bad wolf, has posed as elderly grandparent.'
        expect(component.rows.fifth[:value]).to eq('Yes')

        safeguarding_concerns_row = component.rows[5]

        expect(safeguarding_concerns_row[:key]).to eq(
          'Reason(s) given by referee why this candidate should not work with children',
        )
        expect(safeguarding_concerns_row[:value]).to eq(reference.safeguarding_concerns)
      end
    end

    it 'contains a feedback row' do
      row = component.rows.last
      expect(row[:key]).to eq('Reference')
      expect(row[:value]).to eq(reference.feedback)
    end
  end
end
