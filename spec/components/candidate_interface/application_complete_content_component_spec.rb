require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationCompleteContentComponent do
  let(:submitted_at) { Time.zone.local(2019, 10, 22, 12, 0, 0) }
  let(:first_january_2020) { Time.zone.local(2020, 1, 1, 12, 0, 0) }

  around do |example|
    Timecop.freeze(submitted_at) do
      example.run
    end
  end

  before do
    view_helper = instance_double(ViewHelper)
    allow(view_helper).to receive(:respond_by_date).and_return('1 January 2020')
  end

  context 'when the application is editable' do
    it 'renders with edit content' do
      stub_application_dates_with_form_editable
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_references])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.edit_link'))
    end
  end

  context 'when the application is not editable' do
    it 'renders without edit content' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_references])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).not_to include(t('application_complete.dashboard.edit_link'))
    end
  end

  context 'when the application is waiting for a decision from providers' do
    it 'renders the respond date for providers' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).not_to include(t('application_complete.dashboard.edit_link'))
      expect(render_result.text).to include(t('application_complete.dashboard.providers_respond_by', date: '1 January 2020'))
    end
  end

  context 'when the application has an offer from a provider' do
    it 'renders with some providers have made a decision content' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[offer awaiting_provider_decision])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.some_provider_decisions_made'))
      expect(render_result.text).to include(t('application_complete.dashboard.providers_respond_by', date: '1 January 2020'))
    end
  end

  context 'when the application has all decisions from providers' do
    it 'renders with all providers have made a decision content if all offers' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[offer offer])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.all_provider_decisions_made'))
      expect(render_result.text).to include(t('application_complete.dashboard.candidate_respond_by', remaining_days: '14', date: '5 November 2019'))
    end

    it 'renders with all providers have made a decision content if an offer and rejected' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[offer rejected])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.all_provider_decisions_made'))
      expect(render_result.text).to include(t('application_complete.dashboard.candidate_respond_by', remaining_days: '14', date: '5 November 2019'))
    end

    it 'renders when all offers have been withdrawn' do
      application_form = create(:completed_application_form, :without_application_choices)

      create(:application_choice, application_form: application_form, status: :withdrawn)

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.all_withdrawn'))
    end

    it 'renders when one offer has been withdrawn and one offered' do
      application_form = create(:completed_application_form, :without_application_choices)

      create(:application_choice, application_form: application_form, status: :withdrawn)
      create(:application_choice, application_form: application_form, status: :offer, decline_by_default_at: 1.day.from_now)

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.all_provider_decisions_made'))
    end

    it 'renders when the only offer has been rejected' do
      application_form = create(:completed_application_form, :without_application_choices)

      create(:application_choice, application_form: application_form, status: :rejected)

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.all_provider_decisions_made'))
    end
  end

  context 'when the application has accepted an offer' do
    it 'renders with accepted offer content' do
      stub_application_dates_with_form_uneditable
      application_form = create_application_form_with_course_choices(statuses: %w[pending_conditions declined])

      render_result = render_inline(described_class, application_form: application_form)

      expect(render_result.text).to include(t('application_complete.dashboard.accepted_offer'))
    end
  end

  def stub_application_dates_with_form_uneditable
    application_dates = instance_double(
      ApplicationDates,
      form_open_to_editing?: false,
      reject_by_default_at: first_january_2020,
      decline_by_default_at: 10.business_days.after(submitted_at),
    )
    allow(ApplicationDates).to receive(:new).and_return(application_dates)
  end

  def stub_application_dates_with_form_editable
    application_dates = instance_double(
      ApplicationDates,
      form_open_to_editing?: true,
      days_remaining_to_edit: 5,
      edit_by: Time.zone.local(2019, 10, 29, 12, 0, 0),
      submitted_at: Time.zone.local(2019, 10, 22, 12, 0, 0),
      reject_by_default_at: first_january_2020,
    )
    allow(ApplicationDates).to receive(:new).and_return(application_dates)
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = create(:application_form)

    statuses.each do |status|
      create(
        :application_choice,
        application_form: application_form,
        status: status,
        reject_by_default_at: first_january_2020,
      )
    end

    application_form
  end
end
