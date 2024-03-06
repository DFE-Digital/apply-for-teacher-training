require 'rails_helper'

RSpec.describe ProviderInterface::ReferenceWithFeedbackComponent do
  describe '#rows' do
    let(:feedback) { 'A valuable unit of work' }
    let(:reference) { build(:reference, feedback:) }

    subject(:component) { described_class.new(reference:, index: 0) }

    it 'contains a name row' do
      row = component.rows.first
      expect(row[:key]).to eq('Name')
      expect(row[:value]).to eq(reference.name)
    end

    it 'contains an email address row' do
      row = component.rows.second
      expect(row[:key]).to eq('Email address')
      expect(row[:value]).to include(reference.email_address)
    end

    it 'contains a type of reference row' do
      row = component.rows.third
      expect(row[:key]).to eq('Type of reference')
      expect(row[:value]).to include(reference.referee_type.capitalize.dasherize)
    end

    context 'referee_type is nil' do
      let(:reference) { build(:reference, feedback:, referee_type: nil) }

      it 'renders without raisin an error' do
        row = component.rows.third
        expect(row[:key]).to eq('Type of reference')
        expect(row[:value]).to eq('')
      end
    end

    it 'contains a relationship row' do
      row = component.rows.fourth
      expect(row[:key]).to eq('Relationship between candidate and referee')
      expect(row[:value]).to eq(reference.relationship)
    end

    context 'referee relationship confirmation' do
      it 'contains a confirmation row' do
        expect(component.rows.fifth[:key]).to eq('Relationship confirmed by referee?')
      end

      it 'affirms the referee relationship when uncorrected' do
        expect(component.rows.fifth[:value]).to eq('Yes')
      end

      it 'contains a correction as the row value when corrected' do
        reference.relationship_correction = 'This is not correct'

        expect(component.rows.fifth[:value]).to eq('No')

        correction_row = component.rows[5]

        expect(correction_row[:key]).to eq('Relationship amended by referee')
        expect(correction_row[:value]).to eq('This is not correct')
      end
    end

    context 'safeguarding' do
      let(:safeguarding_row) { component.rows[5] }
      let(:safeguarding_concerns_row) { component.rows[6] }

      it 'contains a safeguarding row' do
        expect(safeguarding_row[:key]).to eq(
          'Does the referee know of any reason why this candidate should not work with children?',
        )
      end

      it 'affirms safeguarding when no safeguarding concerns are present' do
        expect(safeguarding_row[:value]).to eq('No')
      end

      it 'contains safeguarding concerns where present' do
        reference.safeguarding_concerns = 'Is a big bad wolf, has posed as elderly grandparent.'
        reference.safeguarding_concerns_status = :has_safeguarding_concerns_to_declare
        expect(safeguarding_row[:value]).to eq('Yes')

        expect(safeguarding_concerns_row[:key]).to eq(
          'Reasons given by referee why this candidate should not work with children',
        )
        expect(safeguarding_concerns_row[:value]).to eq(reference.safeguarding_concerns)
      end

      it 'does not contain safeguarding concerns when nil' do
        expect(safeguarding_concerns_row[:key]).to eq('Reference')
      end
    end

    context 'feedback' do
      it 'contains a feedback row' do
        row = component.rows.last
        expect(row[:key]).to eq('Reference')
        expect(row[:value]).to eq(reference.feedback)
      end

      it 'contains a feedback row with "Not answered" when feedback is nil' do
        reference.feedback = nil
        row = component.rows.last
        expect(row[:key]).to eq('Reference')
        expect(row[:value]).to eq('Not answered')
      end
    end
  end
end
