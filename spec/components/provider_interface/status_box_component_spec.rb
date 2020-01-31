require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponent do
  it 'outputs a date for applications in the awaiting_provider_decision state' do
    application_choice = make_choice(status: 'awaiting_provider_decision', reject_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Respond to the candidate by')
  end

  it 'outputs a date for applications in the withdrawn state' do
    application_choice = make_choice(status: 'withdrawn', withdrawn_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Application withdrawn')
  end

  it 'outputs a date for applications in the offer state' do
    application_choice = make_choice(status: 'offer', decline_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Candidate must respond by:')
  end

  it 'outputs a date for applications in the rejected state' do
    application_choice = make_choice(status: 'rejected', rejected_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Rejected on')
  end

  it 'outputs a date for applications in the pending_conditions (offer accepted) state' do
    application_choice = make_choice(status: 'pending_conditions', accepted_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Offer accepted:')
  end

  it 'outputs a date for applications in the declined state' do
    application_choice = make_choice(status: 'declined', declined_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Declined on:')
  end

  it 'outputs a date for applications in the recruited state' do
    application_choice = make_choice(status: 'recruited', recruited_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Recruited on:')
  end

  it 'outputs a date for applications in the conditions_not_met state' do
    application_choice = make_choice(status: 'conditions_not_met', conditions_not_met_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Conditions not met')
  end

  it 'outputs a date for applications in the enrolled_at state' do
    now = Time.zone.now
    application_choice = make_choice(status: 'enrolled', enrolled_at: now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Enrolled on:')
    expect(result.text).to include(now.to_s(:govuk_date))
  end

  it 'handles nil `enrolled_at` date for applications in the enrolled_at state' do
    application_choice = make_choice(status: 'enrolled', enrolled_at: nil)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.text).to include('Enrolled on:')
  end

  it 'outputs a `Respond to application` button when the offer is in the `awaiting_provider_decision` state' do
    application_choice = make_choice(status: 'awaiting_provider_decision', reject_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.css('.govuk-button')[0].text).to include('Respond to application')
  end

  it 'outputs an `Edit response` button when the offer is in the `offer` state' do
    application_choice = make_choice(status: 'offer', decline_by_default_at: Time.zone.now)

    result = render_inline(described_class, application_choice: application_choice)

    expect(result.css('.govuk-button')[0].text).to include('Edit response')
  end

  def make_choice(attrs)
    application_form = create(:application_form, submitted_at: Time.zone.now)
    create(:application_choice, { application_form: application_form }.merge(attrs))
  end
end
