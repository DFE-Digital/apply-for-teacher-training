require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
  around do |example|
    @now = Time.zone.local(2020, 2, 11, 22, 0, 0)
    Timecop.freeze(@now) do
      example.run
    end
  end

  def setup_application(changes)
    application_choice = create(:application_choice)
    finder_service = instance_double(FindStatusChangeAudits, call: changes)
    allow(FindStatusChangeAudits).to receive(:new).with(
      application_choice: application_choice,
    ).and_return(finder_service)
    allow(application_choice).to receive(:notes).and_return([])
    allow(application_choice).to receive(:rejected_by_default)
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
      application_choice = setup_application([])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end

  context 'for a submitted application sent to provider' do
    it 'renders submit event' do
      application_choice = setup_application([
        FindStatusChangeAudits::StatusChange.new('awaiting_provider_decision', 5.days.ago, candidate),
      ])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Application submitted'
      expect(rendered.text).to include 'candidate'
      expect(rendered.text).to include '6 February 2020 at 10:00pm'
      expect(rendered.css('a').text).to eq 'View application'
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}"
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
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include '8 February 2020 at 10:00pm'
      expect(rendered.css('a').text).to eq 'View offer'
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/offer"
    end
  end

  context 'for an application with a note' do
    it 'renders note event' do
      application_choice = create(:application_choice)
      note = Note.new(
        provider_user: provider_user,
        subject: 'This is a note',
        message: 'Notes are a new feature',
      )
      application_choice.notes << note
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Note added'
      expect(rendered.text).to include 'Bob Roberts'
      expect(rendered.text).to include '11 February 2020 at 10:00pm'
      expect(rendered.css('a').text).to eq 'View note'
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}/notes/#{note.id}"
    end
  end

  context 'for an application with reject by default feedback' do
    it 'renders feedback event' do
      application_choice = create(:application_choice, :with_rejection_by_default_and_feedback)
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Feedback sent'
      expect(rendered.text).to include '11 February 2020 at 10:00pm'
      expect(rendered.css('a').text).to eq 'View feedback'
      expect(rendered.css('a').attr('href').value).to eq "/provider/applications/#{application_choice.id}"
    end
  end

  it 'has a title for all state transitions' do
    expect(ApplicationStateChange.states_visible_to_provider).to match_array(ProviderInterface::ApplicationTimelineComponent::TITLES.keys.map(&:to_sym))
  end
end
