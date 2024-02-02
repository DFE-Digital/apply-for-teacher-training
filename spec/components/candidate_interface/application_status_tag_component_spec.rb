require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationStatusTagComponent, :continuous_applications do
  let(:course) { create(:course) }

  ApplicationStateChange.valid_states.each do |state_name|
    it "renders with a #{state_name} application choice" do
      render_inline described_class.new(application_choice: create(:application_choice, :continuous_applications, course:, status: state_name))
    end
  end

  context 'when the application choice is in the application_not_sent state' do
    it 'tells the candidate why their application was not sent to their provider(s)' do
      application_choice = create(:application_choice, :application_not_sent, course:)
      result = render_inline(described_class.new(application_choice:))
      expect(result.text).to include('Your application was not sent for this course because it was not submitted before the deadline.')
    end
  end

  context 'when the application choice is in the `interviewing` state' do
    it 'renders the correct content' do
      application_choice = create(
        :application_choice,
        :interviewing,
        reject_by_default_at: 5.days.from_now,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include(
        'If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.',
      )
    end
  end

  context 'when the application choice is in the `awaiting_provider_decision` state' do
    it 'renders the correct content' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        sent_to_provider_at: Time.zone.now,
        reject_by_default_at: 14.days.from_now,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include(
        'If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.',
      )
      expect(result.text).to include('Application submitted today.')

      expect(result.text).not_to include('You can add an application for a different training provider while you wait for a decision on this application')
    end

    context 'when the application was submitted 1 day ago' do
      it 'renders the correct content' do
        application_choice = create(
          :application_choice,
          :awaiting_provider_decision,
          sent_to_provider_at: 1.day.ago,
        )
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include('Application submitted 1 day ago.')
      end
    end

    context 'when the application was submitted more than a day ago' do
      it 'renders the correct content' do
        application_choice = create(
          :application_choice,
          :awaiting_provider_decision,
          sent_to_provider_at: 3.days.ago,
        )
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include('Application submitted 3 days ago.')
      end
    end

    it 'handles nil values for `reject_by_default_at`' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        reject_by_default_at: nil,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).not_to include('You’ll get a decision on your application by')
    end
  end

  context 'when the application choice is in the `inactive` state' do
    context 'when the candidate can add additional choices' do
      it 'renders the correct content' do
        application_choice = create(
          :application_choice,
          :inactive,
          reject_by_default_at: 14.days.from_now,
        )
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).not_to include(
          'If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.',
        )
        expect(result.text).to include('Application submitted today.')

        expect(result.text).to include('You can add an application for a different training provider while you wait for a decision on this application')
      end
    end

    context 'when the candidate cannot add additional choices' do
      it 'renders the correct content' do
        application_form = create(:application_form, application_choices: build_list(:application_choice, 4, status: 'awaiting_provider_decision'))

        application_choice = create(
          :application_choice,
          :inactive,
          application_form:,
          reject_by_default_at: 14.days.from_now,
        )
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include(
          'If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.',
        )

        expect(result.text).to include('Application submitted today.')

        expect(result.text).not_to include('You can add an application for a different training provider while you wait for a decision on this application')
      end
    end
  end

  context 'when the application choice is in the offer_deferred state' do
    it 'tells the candidate when their current course will start' do
      current_course = create(:course, start_date: Date.parse('2022-09-01'))
      application_choice = create(:application_choice, :offer_deferred, course:, current_course:)
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include('Your training will now start in September 2023.')
    end

    context 'when the application choice is in the pending_conditions state' do
      it 'provides guidance on how to defer your application' do
        application_choice = create(:application_choice, :pending_conditions, course:)
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include('You can defer your offer and start your course a year later.')
      end
    end

    context 'when the application choice is in the recruited state' do
      it 'provides guidance on how to defer your application' do
        application_choice = create(:application_choice, :recruited, course:)
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include('You can defer your offer and start your course a year later.')
      end
    end

    context 'when the application choice is in the offer state' do
      it 'provides guidance on how to defer your application' do
        application_choice = create(:application_choice, :offer, course:)
        result = render_inline(described_class.new(application_choice:))

        expect(result.text).to include('If your provider agrees, you’ll need to accept the offer first.')
      end
    end
  end

  context 'provider withdraws an application choice on behalf of the candidate' do
    it 'displays additional guidance' do
      application_choice = create(:application_choice, :offered)

      allow(application_choice).to receive(:withdrawn_at_candidates_request?).and_return(true)

      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include(
        'You requested to withdraw your application. If you did not request this, email becomingateacher@digital.education.gov.uk.',
      )
    end
  end

  context 'candidate withdraws their own application' do
    it 'does not display additional guidance' do
      application_choice = create(:application_choice, :offered)

      allow(application_choice).to receive(:withdrawn_at_candidates_request?).and_return(false)

      result = render_inline(described_class.new(application_choice: application_choice.reload))

      expect(result.text).not_to include(
        'You requested to withdraw your application. If you did not request this, email becomingateacher@digital.education.gov.uk.',
      )
    end

    it 'does not render the reject by default date' do
      application_choice = create(
        :application_choice,
        :offered,
        reject_by_default_at: 5.days.from_now,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).not_to include('You’ll get a decision on your application by')
    end
  end

  context 'when the unsubmitted application choice is from a continuous application' do
    let(:application_choice) { create(:application_choice, :continuous_applications, :unsubmitted, course:) }
    let(:result) { render_inline(described_class.new(application_choice:)) }

    context 'when the course has availability' do
      it 'renders the `Continue application` link' do
        expect(result.text).to include('Continue application')
      end
    end

    context 'then the course has no availability' do
      let(:course) { create(:course, :with_no_vacancies) }

      it 'does not render the `Continue application` link' do
        expect(result.text).not_to include('Continue application')
      end
    end
  end

  it 'renders with `ske_pending_condition` supplementary status for `recruited` applications' do
    application_choice = build_stubbed(:application_choice, status: :recruited)
    allow(application_choice).to receive(:supplementary_statuses).and_return([:ske_pending_conditions])

    result = render_inline described_class.new(application_choice:)
    expect(result.text).to include('Offer confirmed')
    expect(result.text).to include('SKE conditions pending')
  end
end
