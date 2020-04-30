require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
  around do |example|
    @now = Time.zone.local(2020, 2, 11)
    Timecop.freeze(@now) do
      example.run
    end
  end

  def setup_application(changes)
    application_choice = instance_double(ApplicationChoice)
    finder_service = instance_double(FindStatusChangeAudits, call: changes)
    allow(FindStatusChangeAudits).to receive(:new).with(
      application_choice: application_choice,
    ).and_return(finder_service)
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

  context 'without feature flag' do
    it 'renders nothing' do
      application_choice = setup_application([])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to eq ''
    end
  end

  context 'with feature flag' do
    before do
      FeatureFlag.activate('timeline')
    end

    context 'for a newly created application' do
      it 'renders empty timeline' do
        application_choice = setup_application([])
        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.text).to include 'Timeline'
      end
    end

    context 'for a submitted application not sent to provider' do
      it 'does not renders any events event' do
        application_choice = setup_application([
          FindStatusChangeAudits::StatusChange.new('awaiting_references', 20.days.ago, candidate),
        ])
        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.text).to include 'Timeline'
        expect(rendered.text).not_to include 'Application submitted'
      end
    end

    context 'for a submitted application sent to provider' do
      it 'renders submit event' do
        application_choice = setup_application([
          FindStatusChangeAudits::StatusChange.new('awaiting_references', 20.days.ago, candidate),
          FindStatusChangeAudits::StatusChange.new('application_complete', 10.days.ago, candidate),
          FindStatusChangeAudits::StatusChange.new('awaiting_provider_decision', 5.days.ago, candidate),
        ])
        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.text).to include 'Timeline'
        expect(rendered.text).to include 'Application submitted'
        expect(rendered.text).to include 'by candidate'
        expect(rendered.text).to include '6 Feb 2020'
      end
    end

    context 'for an offered application' do
      it 'renders offer event' do
        application_choice = setup_application([
          FindStatusChangeAudits::StatusChange.new('offer', 3.days.ago, provider_user),
        ])
        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.text).to include 'Timeline'
        expect(rendered.text).to include 'Offer made'
        expect(rendered.text).to include 'by Bob Roberts'
        expect(rendered.text).to include '8 Feb 2020'
      end
    end

    context 'for an application with a note' do
      it 'renders note event' do
        application_choice = create(:application_choice)
        application_choice.notes << Note.new(
          provider_user: provider_user,
          subject: 'This is a note',
          message: 'Notes are a new feature',
        )
        rendered = render_inline(described_class.new(application_choice: application_choice))
        expect(rendered.text).to include 'Note added'
        expect(rendered.text).to include 'by Bob Roberts'
        expect(rendered.text).to include '11 Feb 2020'
      end
    end
  end
end
