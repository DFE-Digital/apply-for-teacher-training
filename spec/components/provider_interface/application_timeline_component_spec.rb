require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
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
    @provider_user ||= ProviderUser.new
  end

  context 'for a newly created application' do
    it 'renders empty timeline' do
      application_choice = setup_application([])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end

  context 'for an accepted application' do
    it 'renders sumbit, offer and accept events' do
      application_choice = setup_application([
        FindStatusChangeAudits::StatusChange.new('awaiting_references', 20.days.ago, candidate),
        FindStatusChangeAudits::StatusChange.new('application_complete', 10.days.ago, candidate),
        FindStatusChangeAudits::StatusChange.new('awaiting_provider_decision', 5.days.ago, nil),
        FindStatusChangeAudits::StatusChange.new('offer', 3.days.ago, provider_user),
        FindStatusChangeAudits::StatusChange.new('pending_conditions', 1.day.ago, candidate),
      ])
      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end
end
