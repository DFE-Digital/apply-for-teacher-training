require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationDashboardCourseChoicesComponent do
  context 'when course choices are editable' do
    let(:application_form) do
      create_application_form_with_course_choices(statuses: %w[unsubmitted])
    end

    it 'renders component with correct values for a course' do
      application_choice = application_form.application_choices.first
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
      expect(result.css('.app-course-choice__course-name').to_html).to include("#{application_choice.course.name} (#{application_choice.course.code})")
      expect(result.css('a').to_html).to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
    end

    context 'when Find is down' do
      it 'removes the link to Find' do
        Timecop.travel(EndOfCycleTimetable.find_closes.end_of_day + 1.hour) do
          application_choice = application_form.application_choices.first
          result = render_inline(described_class.new(application_form: application_form))

          expect(result.css('.app-course-choice__course-name').to_html).to include("#{application_choice.course.name} (#{application_choice.course.code})")
          expect(result.css('a').to_html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
        end
      end
    end

    context 'When only one course available at a provider' do
      let(:application_choice) { application_form.application_choices.first }

      it 'renders the course row without change link' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.app-summary-card__actions').text).not_to include("Change course for #{application_choice.course.name_and_code}")
      end
    end

    context 'When a course has both study modes available' do
      let(:application_choice) { application_form.application_choices.first }
      let(:result) { render_inline(described_class.new(application_form: application_form)) }

      before do
        application_choice.course.update!(study_mode: 'full_time_or_part_time')
      end

      it 'renders study mode values' do
        expect(result.css('.govuk-summary-list__key').text).to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).to include(application_choice.offered_option.study_mode.humanize.to_s)
      end

      it 'renders the study mode change link' do
        change_location_link = result.css('.govuk-summary-list__actions')[0].text.strip

        expect(change_location_link).to eq("Change study mode for #{application_choice.course.name_and_code}")
      end
    end

    context 'When a course has one available study mode' do
      let(:application_choice) { application_form.application_choices.first }

      before do
        application_choice.course.update!(study_mode: %w[full_time part_time].sample)
      end

      it 'renders without the study mode row or change link' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__key').text).not_to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).not_to include(application_choice.offered_option.study_mode.humanize.to_s)
        expect(result.css('.app-summary-card__actions').text).not_to include("Change study mode for #{application_choice.course.name_and_code}")
      end
    end

    it 'renders component along with a delete link for each course' do
      application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

      result = render_inline(described_class.new(application_form: application_form))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.delete'))
      expect(result.css('.app-summary-card__actions a[data-action=delete]')).to be_present
    end

    it 'renders component with correct values for multiple courses' do
      result = render_inline(described_class.new(application_form: application_form))

      application_form.application_choices.each do |application_choice|
        expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
      end
    end

    context 'when course choice is single site' do
      it 'renders without the "Change" location links' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when other site option is a different study mode for course' do
      before do
        create(:course_option, course: application_form.application_choices.first.course, study_mode: 'part_time')
      end

      it 'renders without the "Change" location links' do
        result = render_inline(described_class.new(application_form: application_form))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when course is unavailable' do
      it 'renders with the unavailable course text' do
        application_form = create(:application_form)
        create(
          :submitted_application_choice,
          application_form: application_form,
          course_option: create(:course_option, :no_vacancies),
        )

        result = render_inline(described_class.new(application_form: application_form, editable: true))

        expect(result.text).to include('it is not running')
      end
    end
  end

  context 'when course choices are not editable' do
    it 'renders component without a delete link and with a withdraw link' do
      application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

      result = render_inline(described_class.new(application_form: application_form, editable: false))

      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
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

      it 'renders study mode values' do
        expect(result.css('.govuk-summary-list__key').text).to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).to include(application_choice.offered_option.study_mode.humanize.to_s)
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

  context 'when a course choice is withdrawn by provider' do
    it 'renders component with the status as Offer withdrawn and displays the reason' do
      application_form = create(:application_form)
      create(
        :application_choice,
        application_form: application_form,
        status: 'offer_withdrawn',
        offer_withdrawn_at: Time.zone.now,
        offer_withdrawal_reason: 'Course full',
      )

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer withdrawn')
      expect(result.css('.govuk-summary-list__key').text).to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Course full')
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
      application_form = create_application_form_with_course_choices(statuses: %w[offer])

      result = render_inline(described_class.new(application_form: application_form, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer received')
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
