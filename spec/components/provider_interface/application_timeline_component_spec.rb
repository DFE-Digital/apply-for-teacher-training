require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
  include Rails.application.routes.url_helpers

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  def application_choice_with_audits(audits)
    application_choice = audits.first&.auditable || create(:application_choice)
    allow(GetActivityLogEvents).to receive(:call).with(
      application_choices: ApplicationChoice.where(id: application_choice.id),
    ).and_return(audits)
    allow(application_choice).to receive(:notes).and_return([])
    application_choice
  end

  def candidate
    @candidate ||= Candidate.new
  end

  def provider_user
    @provider_user ||= ProviderUser.new(
      first_name: 'Bob',
      last_name: 'Roberts',
      email_address: 'bob.roberts@example.com',
    )
  end

  context 'for a newly created application' do
    it 'renders empty timeline' do
      application_choice = application_choice_with_audits []
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end

  context 'for an application received by provider' do
    it 'renders submit event' do
      audit = create(
        :application_choice_audit,
        :awaiting_provider_decision,
        user: candidate,
        created_at: 5.days.ago,
      )
      application_choice = application_choice_with_audits [audit]

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Application received'
      expect(rendered.text).to include 'Candidate'
      expect(rendered.text).to include 5.days.ago.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View application'
      expect(rendered.css('.govuk-visually-hidden').text).to eq 5.days.ago.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq provider_interface_application_choice_path(application_choice)
    end
  end

  context 'for an offered application' do
    it 'renders offer event' do
      audit = create(
        :application_choice_audit,
        :with_offer,
        user: provider_user,
        created_at: 3.days.ago,
      )
      application_choice = application_choice_with_audits [audit]

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Offer made'
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include 3.days.ago.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View offer'
      expect(rendered.css('.govuk-visually-hidden').text).to eq 3.days.ago.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq provider_interface_application_choice_offer_path(application_choice)
    end
  end

  context 'for an application with a note' do
    it 'renders note event' do
      application_choice = create(:application_choice)
      note = Note.new(
        provider_user: provider_user,
        message: 'Notes are a new feature',
      )
      application_choice.notes << note
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Note added'
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View note'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/notes/#{note.id}"
    end
  end

  context 'for an application with reject by default feedback' do
    it 'renders feedback event' do
      application_choice = create(:application_choice, :with_rejection_by_default_and_feedback)
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Feedback sent'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View feedback'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/feedback"
    end
  end

  context 'for an application with a change offer event' do
    it 'renders the change offer event' do
      application_choice = create(:application_choice, :with_changed_offer)
      create(:application_choice_audit, :with_changed_offer, application_choice: application_choice)
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Offer changed'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View offer'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq provider_interface_application_choice_offer_path(application_choice)
    end
  end

  context 'for an interview event' do
    it 'renders the interview set up event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice: application_choice, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, interview: interview, application_choice: application_choice, audited_changes: {})
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Interview set up'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}"
    end

    it 'renders the interview updated event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice: application_choice, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, action: 'update', interview: interview, application_choice: application_choice, audited_changes: {})
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Interview updated'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}"
    end

    it 'renders the interview cancelled event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice: application_choice, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, action: 'update', interview: interview, application_choice: application_choice, audited_changes: { cancelled_at: [nil, Time.zone.now] })
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Interview cancelled'
      expect(rendered.text).to include Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq Time.zone.now.to_s(:govuk_date_and_time)
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}"
    end
  end

  describe 'user who made the changes' do
    let(:user) { build_stubbed(:support_user) }
    let(:username) { nil }
    let(:audit) do
      create(
        :application_choice_audit,
        :with_offer,
        user: user,
        username: username,
        created_at: 3.days.ago,
      )
    end

    context 'when change was done by a support user' do
      it 'renders Apply support' do
        application_choice = application_choice_with_audits [audit]

        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Apply support'
      end
    end

    context 'when change was done in the rails console' do
      let(:user) { nil }
      let(:username) { 'John Smith via the Rails console' }

      it 'renders Apply support' do
        application_choice = application_choice_with_audits [audit]

        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Apply support'
      end
    end

    context 'when change was done by an automated process' do
      let(:user) { nil }
      let(:username) { '(Automated process)' }

      it 'renders System' do
        application_choice = application_choice_with_audits [audit]

        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'System'
      end
    end
  end

  it 'has a title for all state transitions' do
    FeatureFlag.activate(:interviews)
    expect(ApplicationStateChange.states_visible_to_provider).to match_array(ProviderInterface::ApplicationTimelineComponent::TITLES.keys.map(&:to_sym))
  end
end
