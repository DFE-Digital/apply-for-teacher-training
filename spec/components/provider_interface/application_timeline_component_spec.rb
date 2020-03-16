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
    application_choice
  end

  def candidate
    @candidate ||= Candidate.new
  end

  def provider_user
    @provider_user ||= ProviderUser.new(first_name: 'Bob', last_name: 'Roberts')
  end

  context 'for a newly created application' do
    it 'renders empty timeline' do
      application_choice = setup_application([])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end

  context 'for a submitted application' do
    it 'renders submit event' do
      application_choice = setup_application([
        FindStatusChangeAudits::StatusChange.new('awaiting_references', 20.days.ago, candidate),
      ])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
      expect(rendered.text).to include 'Application submitted'
      expect(rendered.text).to include 'by candidate'
      expect(rendered.text).to include '22 Jan 2020'
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
end
