require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoiceComponent do
  context 'Declined offer' do
    let(:declined_offer) { create(:application_choice, :with_completed_application_form, :with_declined_offer) }

    it 'Renders a link to the reinstate offer page when the reinstate flag is active' do
      FeatureFlag.activate(:support_user_reinstate_offer)

      result = render_inline(described_class.new(declined_offer))

      expect(result.css('.govuk-summary-list__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.support_interface_application_form_reinstate_offer_path(
          application_form_id: declined_offer.application_form.id,
          application_choice_id: declined_offer.id,
        ),
      )
      expect(result.css('.govuk-summary-list__actions').text.strip).to include('Reinstate offer')
    end

    it 'Does not render a link to the reinstate offer page when the reinstate flag is not active' do
      FeatureFlag.deactivate(:support_user_reinstate_offer)

      render_inline(described_class.new(declined_offer))

      expect(page).not_to have_selector '.govuk-summary-list__actions a'
      expect(page).not_to have_text 'Reinstate offer'
    end

    it 'Does not render a link to the reinstate offer page if the application choice is declined by default' do
      application_choice = create(:application_choice, :with_completed_application_form, :with_declined_by_default_offer)

      FeatureFlag.activate(:support_user_reinstate_offer)

      render_inline(described_class.new(application_choice))

      expect(page).not_to have_selector '.govuk-summary-list__actions a'
      expect(page).not_to have_text 'Reinstate offer'
    end
  end

  it 'displays the date an application was rejected' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :with_rejection,
                                rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected at')
    expect(result.text).to include('1 January 2020 at 10am')
  end

  it 'displays the date an application was rejected by default' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :with_rejection_by_default,
                                rejected_at: Time.zone.local(2020, 1, 1, 10, 0, 0))

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejected by default at')
    expect(result.text).to include('1 January 2020 at 10am')
  end

  it 'displays reasons for rejection on rejected application with structured reasons' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :with_structured_rejection_reasons)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include('Something you did')
    expect(result.text).to include('Persistent scratching')
  end

  it 'displays reasons for rejection on rejected application without structured reasons' do
    application_choice = create(:application_choice,
                                :with_completed_application_form,
                                :with_rejection)

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Rejection reason')
    expect(result.text).to include(application_choice.rejection_reason)
  end

  it 'displays offer date and DBD date for offered applications' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :with_offer,
      offered_at: Time.zone.local(2020, 1, 1, 10),
      decline_by_default_at: Time.zone.local(2020, 1, 10, 10),
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Offer made at')
    expect(result.text).to include('1 January 2020 at 10am')

    expect(result.text).to include('Decline by default at')
    expect(result.text).to include('10 January 2020 at 10am')
  end

  it 'does not display DBD date for offered applications when it has not yet been set' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :with_offer,
      offered_at: Time.zone.local(2020, 1, 1, 10),
      decline_by_default_at: nil,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).not_to include('Decline by default at')
  end

  it 'displays the course offered by the provider when the applied course is different' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :with_offer,
      current_course_option: create(:course_option),
      offered_at: Time.zone.local(2020, 1, 1, 10),
      decline_by_default_at: nil,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('Course offered by provider')
  end

  it 'offers the Vendor and Register API representations if appropriate' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :awaiting_provider_decision,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('See this application as it appears over the Vendor API')
    expect(result.text).to include('the application isn’t available over the Register API')
  end

  it 'offers the Register API representation if appropriate' do
    application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :with_recruited,
    )

    result = render_inline(described_class.new(application_choice))

    expect(result.text).to include('See this application as it appears over the Register API')
  end
end
