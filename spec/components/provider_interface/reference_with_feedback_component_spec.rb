require 'rails_helper'

RSpec.describe ProviderInterface::ReferenceWithFeedbackComponent, type: :component do
  it 'renders the row information' do
    reference = build(:reference, feedback: 'A valuable unit of work', feedback_status: 'feedback_provided')
    application_choice = build(:application_choice, :with_completed_application_form, :recruited)

    render_inline(described_class.new(
                    reference:,
                    application_choice:,
                  ))

    expect(page).to have_text("Name#{reference.name}")
    expect(page).to have_text("Email address#{reference.email_address}")
    expect(page).to have_text("How the candidate knows them and how long for#{reference.relationship} This was confirmed by #{reference.name}.")
    expect(page).to have_text('Concerns about the candidate working with childrenNo concerns.')
    expect(page).to have_text("Reference#{reference.feedback}")
    expect(page).to have_text('Can this reference be shared with the candidate?Yes, if they request it.')
  end

  describe '#rows' do
    let(:feedback) { 'A valuable unit of work' }
    let(:reference) { build(:reference, feedback:, feedback_status: 'feedback_provided') }
    let(:application_choice) { build(:application_choice, :with_completed_application_form, :recruited) }

    subject(:component) do
      described_class.new(
        reference:,
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
          value: "The candidate said:\n#{reference.relationship}\n\n#{reference.name} said:\n#{reference.relationship_correction}",
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
        row = component.rows[4]
        expect(row[:key]).to eq('Reference')
        expect(row[:value]).to eq(reference.feedback)
      end

      it 'changes field name when carried over reference' do
        reference.duplicate = true

        row = component.rows[4]
        expect(row[:key]).to eq('Does the candidate have the potential to teach?')
        expect(row[:value]).to eq(reference.feedback)
      end

      it 'does not contain a feedback row when feedback when there is not an offer' do
        reference.feedback = nil
        row = component.rows.last
        expect(row[:key]).not_to eq('Reference')
      end
    end

    context 'confidentiality' do
      it 'contains a confidentiality row explaining that the reference is confidential' do
        reference.confidential = true

        expect(component.rows).to include(
          {
            key: 'Can this reference be shared with the candidate?',
            value: 'No, this reference is confidential. Do not share it.',
          },
        )
      end

      it 'contains a confidentiality row explaining that the reference is not confidential' do
        reference.confidential = false

        expect(component.rows).to include(
          {
            key: 'Can this reference be shared with the candidate?',
            value: 'Yes, if they request it.',
          },
        )
      end

      context 'when feedback has not been provided' do
        let(:reference) { build(:reference, feedback:, feedback_status: 'feedback_requested') }

        it 'does not contain a confidentiality row' do
          expect(component.rows).not_to include(
            {
              key: 'Can this reference be shared with the candidate?',
              value: 'No, this reference is confidential. Do not share it.',
            },
          )
        end
      end
    end

    [
      { application_choice_status: :unsubmitted, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :awaiting_provider_decision, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :inactive, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :interviewing, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :offer, feedback_and_safeguarding_displayed: false }, # The Candidate has not accepted the Offer
      { application_choice_status: :declined, feedback_and_safeguarding_displayed: false }, # Offer has been declined by the Candidate
      { application_choice_status: :offer_withdrawn, feedback_and_safeguarding_displayed: false }, # This can only happen before the Candidate Accepts and offer
      { application_choice_status: :pending_conditions, feedback_and_safeguarding_displayed: true },
      { application_choice_status: :offer_deferred, feedback_and_safeguarding_displayed: true },
      { application_choice_status: :recruited, feedback_and_safeguarding_displayed: true },
      { application_choice_status: :conditions_not_met, feedback_and_safeguarding_displayed: true },
      { application_choice_status: :rejected, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :withdrawn, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :cancelled, feedback_and_safeguarding_displayed: false },
      { application_choice_status: :application_not_sent, feedback_and_safeguarding_displayed: false },
    ].each do |test_case|
      context "when the Application is in the #{test_case[:application_choice_status]} state" do
        let(:application_choice) {
          build(:application_choice,
                :with_completed_application_form,
                status: test_case[:application_choice_status])
        }
        let(:reference) {
          build(:reference,
                feedback: 'A valuable unit of work',
                feedback_status: 'feedback_provided',
                safeguarding_concerns_status: :has_safeguarding_concerns_to_declare,
                safeguarding_concerns: 'Has a history of being a big bad wolf')
        }

        subject(:component) do
          described_class.new(
            reference:,
            application_choice:,
          )
        end

        if test_case[:feedback_and_safeguarding_displayed]
          it 'contains a concern on safeguarding' do
            expect(component.rows).to include(
              {
                key: 'Concerns about the candidate working with children',
                value: 'Has a history of being a big bad wolf',
              },
            )
          end

          it 'contains the feedback row with the feedback details' do
            expect(component.rows).to include(
              {
                key: 'Reference',
                value: 'A valuable unit of work',
              },
            )
          end
        else
          it 'contains no concern on safeguarding' do
            expect(component.rows).not_to include(
              {
                key: 'Concerns about the candidate working with children',
                value: 'Has a history of being a big bad wolf',
              },
            )
          end

          it 'does not contain the feedback row' do
            expect(component.rows).not_to include(
              {
                key: 'Reference',
                value: 'A valuable unit of work',
              },
            )
          end
        end
      end
    end
  end
end
