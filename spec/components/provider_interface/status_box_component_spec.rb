require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponent do
  it 'outputs a date for applications in the awaiting_provider_decision state' do
    application_choice = make_choice(status: 'awaiting_provider_decision', reject_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Respond to the applicant by')
  end

  it 'outputs a date for applications in the withdrawn state' do
    application_choice = make_choice(status: 'withdrawn', withdrawn_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Application withdrawn')
  end

  it 'outputs a date for applications in the offer state' do
    application_choice = make_choice(status: 'offer', decline_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Needs to respond by')
  end

  it 'outputs a date for applications in the rejected state' do
    application_choice = make_choice(status: 'rejected', rejected_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Rejected at')
  end

  it 'outputs a date for applications in the pending_conditions (offer accepted) state' do
    application_choice = make_choice(status: 'pending_conditions', accepted_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Accepted at')
  end

  it 'outputs a date for applications in the declined state' do
    application_choice = make_choice(status: 'declined', declined_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Declined at')
  end

  it 'outputs a date for applications in the recruited state' do
    application_choice = make_choice(status: 'recruited', recruited_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Recruited at')
  end

  it 'outputs a date for applications in the conditions_not_met state' do
    application_choice = make_choice(status: 'conditions_not_met', conditions_not_met_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Conditions not met')
  end

  it 'outputs a date for applications in the enrolled_at state' do
    application_choice = make_choice(status: 'enrolled', enrolled_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Enrolled at')
  end

  def make_choice(attrs)
    application_form = create(:application_form, submitted_at: Time.zone.now)
    create(:application_choice, { application_form: application_form }.merge(attrs))
  end
end
