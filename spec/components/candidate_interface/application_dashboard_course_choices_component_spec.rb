require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationDashboardCourseChoicesComponent do
  it 'renders component without a delete link and with a withdraw link' do
    application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

    result = render_inline(described_class.new(application_form: application_form, editable: false))

    expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
  end

  it 'renders a View application link' do
    application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])

    result = render_inline(described_class.new(application_form: application_form, editable: false))

    expect(result.css('.app-summary-card__actions').text).to include('View application')
  end

  context 'When multiple courses available at a provider' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
    let(:application_choice) { application_form.application_choices.first }

    before do
      provider = application_form.application_choices.first.provider
      create(:course, provider: provider, exposed_in_find: true, open_on_apply: true, study_mode: :full_time)
    end

    it 'renders without the course choice change link' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
    end
  end

  context 'when there are multiple site options for course' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }

    before do
      create(:course_option, course: application_form.application_choices.first.course)
    end

    it 'renders without a "Change" location links' do
      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
    end
  end

  context 'When a course has both study modes available' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
    let(:application_choice) { application_form.application_choices.first }
    let(:result) { render_inline(described_class.new(application_form: application_form, editable: false)) }

    before do
      application_choice.course.update!(study_mode: 'full_time_or_part_time')
    end

    it 'does not render study mode values' do
      expect(result.css('.govuk-summary-list__key').text).not_to include('Full time or part time')
      expect(result.css('.govuk-summary-list__value').text).not_to include(application_choice.current_course_option.study_mode.humanize.to_s)
    end

    it 'renders without the change link' do
      expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
    end
  end

  context 'when course is unavailable' do
    it 'renders without the unavailable course text' do
      application_form = create(:application_form)
      create(
        :submitted_application_choice,
        application_form: application_form,
        course_option: create(:course_option, :no_vacancies),
      )

      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.text).not_to include('it is not running')
    end
  end

  context 'when a course choice is rejected' do
    it 'renders component with the status as rejected and displays the reason' do
      application_form = create(:application_form)
      create(
        :application_choice,
        application_form: application_form,
        status: 'rejected',
        rejection_reason: 'Course full',
      )

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Unsuccessful')
      expect(result.css('.govuk-summary-list__key').text).to include('Feedback')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Course full')
    end
  end

  context 'when a course choice offer is withdrawn by provider' do
    let!(:application_form) { create(:application_form) }
    let!(:application_choice) do
      create(
        :application_choice,
        :with_withdrawn_offer,
        application_form: application_form,
        offer_withdrawal_reason: 'Course full',
      )
    end

    it 'renders component with the status as Offer withdrawn and displays the reason' do
      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer withdrawn')
      expect(result.css('.govuk-summary-list__key').text).to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Course full')
    end

    it 'does not render the reason if an offer is subsequently made' do
      application_choice.offer!

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).not_to include('Course full')
    end
  end

  context 'when a course choice is awaiting provider decision' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision]) }

    it 'renders component with the status as awaiting decision' do
      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Awaiting decision')
    end

    it 'renders component with a withdraw link' do
      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).to include('Withdraw this application')
    end
  end

  context 'when an offer has been made to a course choice' do
    it 'renders component with the status as offer when an offer has been made' do
      conditions = [build(:offer_condition, text: 'DBS check'), build(:offer_condition, text: 'Get a haircut')]
      application_form = create_application_form_with_course_choices(statuses: %w[offer])
      application_choice = application_form.application_choices.first
      create(:offer, application_choice: application_choice, conditions: conditions)

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer received')
      expect(result.css('.govuk-summary-list__key').text).to include('Condition')
      expect(result.css('.govuk-summary-list__value').to_html).to include('DBS check')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Get a haircut')
    end

    it 'renders component with the respond to offer link and message about waiting for providers to respond' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer awaiting_provider_decision])

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).to include('Respond to offer')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(
          application_form.application_choices.offer.first,
        ),
      )
      expect(result.css('.govuk-summary-list__value').text).to include(
        'You can wait to hear back from everyone before you respond.',
      )
    end

    it 'renders component with the respond to offer link and deadline message' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer rejected])

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).not_to include('Respond to application')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(
          application_form.application_choices.offer.first.id,
        ),
      )
      expect(result.css('.govuk-summary-list__value').text).to include(
        "You have 5 days (until #{5.days.from_now.to_s(:govuk_date)}) to respond.",
      )
    end
  end

  context 'when an offer has been accepted i.e. pending conditions to a course choice' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions]) }

    it 'renders component with the status as accepted' do
      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer accepted')
    end

    it 'renders component with a withdraw link' do
      course_id = application_form.application_choices.first.id

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).to include('Withdraw this application')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_withdraw_path(course_id),
      )
    end
  end

  context 'when an offer has been declined to a course choice' do
    it 'renders component with the status as declined' do
      application_form = create_application_form_with_course_choices(statuses: %w[declined])

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer declined')
    end
  end

  context 'when an interview has been scheduled' do
    it 'renders the component with interview details' do
      application_choice = create(:application_choice, :with_completed_application_form, :with_scheduled_interview)
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Interview')
    end
  end

  context 'when an interview has been cancelled and the status is withdrawn' do
    it 'renders the component without interview details' do
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :with_cancelled_interview,
      )
      application_choice.withdrawn!
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Interview')
    end
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = create(:application_form)

    statuses.each do |status|
      create(
        :application_choice,
        application_form: application_form,
        status: status,
        decline_by_default_at: status.to_sym == :offer ? 5.days.from_now : nil,
      )
    end

    application_form
  end
end
