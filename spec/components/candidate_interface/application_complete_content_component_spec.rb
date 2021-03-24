require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationCompleteContentComponent do
  let(:submitted_at) { Time.zone.local(2019, 10, 22, 12, 0, 0) }
  let(:first_january_2020) { Time.zone.local(2020, 1, 1, 12, 0, 0) }

  around do |example|
    Timecop.freeze(submitted_at) do
      example.run
    end
  end

  context 'when the application is waiting for a decision from providers' do
    it 'renders the respond date for providers' do
      stub_application_dates_with_form
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).not_to include(t('application_complete.dashboard.edit_link'))
      expect(render_result.text).to include(t('application_complete.dashboard.providers_respond_by', date: '1 January 2020'))
    end
  end

  context 'when the application has an offer from a provider' do
    it 'renders with some providers have made a decision content' do
      stub_application_dates_with_form
      application_form = create_application_form_with_course_choices(statuses: %w[offer awaiting_provider_decision])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include(t('application_complete.dashboard.some_provider_decisions_made'))
      expect(render_result.text).to include(t('application_complete.dashboard.providers_respond_by', date: '1 January 2020'))
    end
  end

  context 'when the application has all decisions from providers' do
    it 'renders when all offers have been withdrawn' do
      application_form = build_stubbed(:application_form, application_choices: [
        build_stubbed(:application_choice, application_form: application_form, status: :withdrawn),
      ])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include(t('application_complete.dashboard.all_withdrawn', count: 1))
    end
  end

  context 'when the application has accepted an offer' do
    it 'renders with accepted offer content' do
      stub_application_dates_with_form
      application_form = create_application_form_with_course_choices(statuses: %w[pending_conditions declined])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include(t('application_complete.dashboard.accepted_offer'))
    end
  end

  context 'when the application is recruited' do
    it 'renders with recruited content' do
      stub_application_dates_with_form
      application_form = create_application_form_with_course_choices(statuses: %w[recruited declined])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include(t('application_complete.dashboard.recruited'))
    end
  end

  context 'when the application is deferred' do
    it 'renders with deferred content' do
      stub_application_dates_with_form
      application_form = create_application_form_with_course_choices(statuses: %w[offer_deferred declined])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include(t('application_complete.dashboard.deferred'))
    end
  end

  def stub_application_dates_with_form
    application_dates = instance_double(
      ApplicationDates,
      reject_by_default_at: first_january_2020,
      decline_by_default_at: 10.business_days.after(submitted_at),
    )
    allow(ApplicationDates).to receive(:new).and_return(application_dates)
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = build_stubbed(:application_form)
    application_choices = statuses.map do |status|
      build_stubbed(
        :application_choice,
        application_form: application_form,
        status: status,
        reject_by_default_at: first_january_2020,
      )
    end

    allow(application_form).to receive(:application_choices).and_return(application_choices)

    application_form
  end
end
