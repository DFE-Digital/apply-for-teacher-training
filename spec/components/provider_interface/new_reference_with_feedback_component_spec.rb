require 'rails_helper'

RSpec.describe ProviderInterface::NewReferenceWithFeedbackComponent, type: :component do
  describe '#rows' do
    let(:feedback) { 'A valuable unit of work' }
    let(:reference) { build(:reference, feedback:, feedback_status: 'feedback_provided') }
    let(:application_choice) { build(:application_choice, :with_completed_application_form, :with_offer) }

    subject(:component) do
      described_class.new(
        reference:,
        index: 0,
        application_choice:,
      )
    end

    it 'contains a name row' do
      expect(component.rows).to include(
        { key: 'Name', value: reference.name },
      )
    end

    it 'contains an email address row' do
      expect(component.rows).to include(
        { key: 'Email address', value: reference.email_address },
      )
    end

    it 'contains a relationship row' do
      expect(component.rows).to include(
        {
          key: 'How the candidate knows them and how long for',
          value: "#{reference.relationship}\n\nThis was confirmed by #{reference.name}.",
        },
      )
    end

    it 'contains a correction as the row value when corrected' do
      reference.relationship_correction = 'This is not correct'

      expect(component.rows).to include(
        {
          key: 'How the candidate knows them and how long for',
          value: "#{reference.relationship}\n\n#{reference.relationship_correction}",
        },
      )
    end

    context 'safeguarding' do
      it 'contains no concern on safeguarding' do
        expect(component.rows).to include(
          {
            key: 'Concerns about the candidate working with children',
            value: 'No concerns.',
          },
        )
      end

      it 'contains safeguarding concerns where present' do
        reference.safeguarding_concerns = 'Is a big bad wolf, has posed as elderly grandparent.'
        reference.safeguarding_concerns_status = :has_safeguarding_concerns_to_declare

        expect(component.rows).to include(
          {
            key: 'Concerns about the candidate working with children',
            value: reference.safeguarding_concerns,
          },
        )
      end
    end

    context 'feedback' do
      it 'contains a feedback row' do
        row = component.rows.last
        expect(row[:key]).to eq('Reference')
        expect(row[:value]).to eq(reference.feedback)
      end

      it 'changes field name when carried over reference' do
        reference.duplicate = true

        row = component.rows.last
        expect(row[:key]).to eq('Does the candidate have the potential to teach?')
        expect(row[:value]).to eq(reference.feedback)
      end

      it 'does not contain a feedback row when feedback when there is not an offer' do
        reference.feedback = nil
        row = component.rows.last
        expect(row[:key]).not_to eq('Reference')
      end
    end
  end
end
