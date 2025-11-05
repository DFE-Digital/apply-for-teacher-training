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

  describe '#warning_text' do
    it 'returns nil when the reference is not confidential' do
      reference = build(:reference, confidential: false, feedback_status: 'feedback_provided')
      application_choice = build(:application_choice, :with_completed_application_form, :recruited)

      component = described_class.new(reference:, application_choice:)

      expect(component.warning_text).to be_nil
    end

    it 'returns nil when the reference feedback has not been provided' do
      reference = build(:reference, confidential: true, feedback_status: 'feedback_requested')
      application_choice = build(:application_choice, :with_completed_application_form, :recruited)

      component = described_class.new(reference:, application_choice:)

      expect(component.warning_text).to be_nil
    end

    it 'returns a warning message when the reference is confidential and feedback has been provided' do
      reference = build(:reference,
                        confidential: true,
                        feedback_status: 'feedback_provided')
      application_choice = build(:application_choice, :with_completed_application_form, :recruited)

      component = described_class.new(reference:, application_choice:)

      expect(component.warning_text).to eq('Confidential do not share with the candidate')
    end
  end

  describe '#rows' do
    let(:feedback) { 'A valuable unit of work' }
    let(:reference) { build(:reference, feedback:, feedback_status: 'feedback_provided', referee_type: :academic) }
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

    it 'contains a reference type row' do
      expect(component.rows).to include(
        {
          key: 'Reference type',
          value: 'Academic',
        },
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
        row = component.rows[5]
        expect(row[:key]).to eq('Reference')
        expect(row[:value]).to eq(reference.feedback)
      end

      context 'when feedback has not been provided' do
        # The Referee has started the reference but has not submitted the reference yet
        let(:reference) { build(:reference, feedback: 'A valuable unit of work', feedback_status: 'feedback_requested') }

        it 'does not contain a feedback row' do
          expect(component.rows).not_to include(
            {
              key: 'Reference',
              value: 'A valuable unit of work',
            },
          )
        end
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

    context 'when feedback has been provided' do
      let(:time_now) { Time.zone.now }
      let(:reference) do
        build(:reference,
              feedback_status: 'feedback_provided',
              feedback_provided_at: time_now,
              requested_at: time_now - 2.days)
      end
      let(:application_choice) { build(:application_choice, :with_completed_application_form, :recruited) }

      it 'renders the date received row' do
        render_inline(described_class.new(reference:, application_choice:))

        expect(page).to have_text('Date received')
        expect(page).to have_text(time_now.to_fs(:govuk_date_and_time))
      end
    end

    context 'when feedback has not been provided' do
      let(:requested_time) { Time.zone.now }
      let(:reference) do
        build(:reference,
              feedback_status: 'feedback_requested',
              feedback_provided_at: nil,
              requested_at: requested_time)
      end
      let(:application_choice) { build(:application_choice, :with_completed_application_form, :offer) }

      it 'renders the date requested row' do
        render_inline(described_class.new(reference:, application_choice:))

        expect(page).to have_text('Date requested')
        expect(page).to have_text(requested_time.to_fs(:govuk_date_and_time))
      end
    end

    context 'when the reference has not yet been requested' do
      let(:reference) { build(:reference, requested_at: nil) }
      let(:application_choice) { build(:application_choice, :with_completed_application_form, :recruited) }

      it 'does not render any date row' do
        render_inline(described_class.new(reference:, application_choice:))

        expect(page).to have_no_text('Date requested')
        expect(page).to have_no_text('Date received')
      end
    end
  end
end
