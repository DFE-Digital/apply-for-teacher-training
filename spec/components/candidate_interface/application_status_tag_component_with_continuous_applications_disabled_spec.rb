# This file can be deleted with the continuous applications feature flag. The remaining functionality is tested in
# 'application_status_tag_component_spec.rb'

require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationStatusTagComponent, continuous_applications: false do
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
      expect(result.text).to include('Your application was not sent for this course because references were not given before the deadline.')
    end
  end

  context 'when the application choice is in the `interviewing` state' do
    it 'tells the candidate when the reject by default date will be' do
      application_choice = create(
        :application_choice,
        :interviewing,
        reject_by_default_at: 5.days.from_now,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include(
        "You’ll get a decision on your application by #{5.days.from_now.to_fs(:govuk_date)}.",
      )
    end
  end

  context 'when the application choice is in the `awaiting_provider_decision` state' do
    it 'tells the candidate when the reject by default date will be' do
      application_choice = create(
        :application_choice,
        :awaiting_provider_decision,
        reject_by_default_at: 14.days.from_now,
      )
      result = render_inline(described_class.new(application_choice:))

      expect(result.text).to include(
        "You’ll get a decision on your application by #{14.days.from_now.to_fs(:govuk_date)}.",
      )
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
end
