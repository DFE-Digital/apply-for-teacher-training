require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
  include Rails.application.routes.url_helpers

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
      rendered = render_inline(described_class.new(application_choice:))
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

      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Application received'
      expect(rendered.text).to include 'Candidate'
      expect(rendered.text).to include 5.days.ago.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View application'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Application received: Candidate #{5.days.ago.to_fs(:govuk_date_and_time)}"
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

      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Offer made'
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include 3.days.ago.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View offer'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Offer made: Bob Roberts #{3.days.ago.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq provider_interface_application_choice_offer_path(application_choice)
    end
  end

  context 'when an application has a status change to inactive' do
    it 'renders the component excluding the inactive event' do
      inactive_audit = build_stubbed(
        :application_choice_audit,
        audited_changes: { 'status' => %w[offer inactive] },
      )
      application_choice = application_choice_with_audits([inactive_audit])

      expect { render_inline(described_class.new(application_choice: application_choice)) }.not_to raise_error
    end
  end

  context 'for an application with a note' do
    let(:application_choice) { create(:application_choice) }

    it 'renders note event' do
      note = Note.new(
        message: 'Notes are a new feature',
        user: provider_user,
      )
      application_choice.notes << note
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Note added'
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View note'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Note added: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/notes/#{note.id}"
    end

    it 'renders note events by API users' do
      note = Note.new(
        message: 'Notes are a new feature',
        user: create(:vendor_api_user, full_name: 'Jane Smith'),
      )
      application_choice.notes << note
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Jane Smith (Vendor API)'
    end

    it 'renders note events by support users' do
      note = Note.new(
        message: 'Notes are a new feature',
        user: create(:support_user),
      )
      application_choice.notes << note
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Apply support'
    end
  end

  context 'for an application with reject by default feedback' do
    it 'renders feedback event' do
      application_choice = create(:application_choice, :rejected_by_default_with_feedback)
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Feedback sent'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View feedback'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Feedback sent: Apply support #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/feedback"
    end
  end

  context 'for an application with a change offer event' do
    it 'renders the change offer event' do
      application_choice = create(:application_choice, :course_changed_after_offer)
      create(:application_choice_audit, :with_changed_offer, application_choice:, user: provider_user)
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Offer changed'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View offer'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Offer changed: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq provider_interface_application_choice_offer_path(application_choice)
    end
  end

  context 'for an application with a change course event' do
    it 'renders the change course event' do
      application_choice = create(:application_choice)
      create(:application_choice_audit, :with_changed_course, application_choice:, user: provider_user)
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Course updated'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View application'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Course updated: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}"
    end
  end

  context 'for an interview event' do
    it 'renders the interview set up event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice:, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, interview:, application_choice:, audited_changes: {}, user: provider_user)
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])
      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Interview set up'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Interview set up: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}"
    end

    it 'renders the interview updated event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice:, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, action: 'update', interview:, application_choice:, audited_changes: {}, user: provider_user)
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])

      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Interview updated'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Interview updated: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/interviews#interview-#{interview.id}"
    end

    it 'renders the interview cancelled event' do
      application_choice = build_stubbed(:application_choice, status: 'interviewing')
      interview = build_stubbed(:interview)
      application_choice_audit = build_stubbed(:application_choice_audit, application_choice:, audited_changes: { status: %w[awaiting_provider_decision interviewing] })
      interview_audit = build_stubbed(:interview_audit, action: 'update', interview:, application_choice:, audited_changes: { cancelled_at: [nil, Time.zone.now] }, user: provider_user)
      allow(application_choice_audit).to receive(:auditable).and_return(application_choice)
      allow(interview_audit).to receive(:auditable).and_return(interview)
      allow(GetActivityLogEvents).to receive(:call)
        .and_return([interview_audit, application_choice_audit])

      rendered = render_inline(described_class.new(application_choice:))
      expect(rendered.text).to include 'Interview cancelled'
      expect(rendered.text).to include Time.zone.now.to_fs(:govuk_date_and_time)
      expect(rendered.css('a').text).to include 'View interview'
      expect(rendered.css('.govuk-visually-hidden').text).to eq "Interview cancelled: Bob Roberts #{Time.zone.now.to_fs(:govuk_date_and_time)}"
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
        user:,
        username:,
        created_at: 3.days.ago,
      )
    end
    let(:application_choice) { application_choice_with_audits [audit] }

    context 'when change was done by a support user' do
      it 'renders Apply support' do
        rendered = render_inline(described_class.new(application_choice:))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Apply support'
      end
    end

    context 'when change was done in the rails console' do
      let(:user) { nil }
      let(:username) { 'John Smith via the Rails console' }

      it 'renders Apply support' do
        rendered = render_inline(described_class.new(application_choice:))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'Apply support'
      end
    end

    context 'when change was done by an automated process' do
      let(:user) { nil }
      let(:username) { '(Automated process)' }

      it 'renders System' do
        rendered = render_inline(described_class.new(application_choice:))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include 'System'
      end
    end

    context 'when change was done by the vendor api' do
      let(:user) { create(:vendor_api_user) }

      it 'exposes the vendor Api users name' do
        rendered = render_inline(described_class.new(application_choice:))
        expect(rendered.css('.app-timeline__actor_and_date').text).to include "#{user.full_name} (Vendor API)"
      end
    end
  end

  it 'has a title for all state transitions' do
    expect(ApplicationStateChange.states_visible_to_provider - %i[inactive]).to match_array(ProviderInterface::ApplicationTimelineComponent::TITLES.keys.map(&:to_sym))
  end
end
