require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoicesReviewComponent, :mid_cycle, type: :component do
  context 'when course choices are not editable' do
    it 'renders component without a delete link and with a withdraw link' do
      application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
    end

    it 'shows the application number' do
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])
      render_inline(described_class.new(application_form:)) do |rendered_component|
        expect(rendered_component).to include 'Application number'
        expect(rendered_component).to include application_form.application_choices.first.id.to_s
      end
    end

    context 'When multiple courses available at a provider' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
      let(:application_choice) { application_form.application_choices.first }

      before do
        provider = application_form.application_choices.first.provider
        build(:course, provider:, study_mode: :full_time)
      end

      it 'renders without the course choice change link' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when there are multiple site options for course' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }

      before do
        build(:course_option, course: application_form.application_choices.first.course)
      end

      it 'renders without a "Change" location links' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when the placement school is auto selected' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }

      before do
        build(:course_option, course: application_form.application_choices.first.course)
        application_form.application_choices.first.update(school_placement_auto_selected: true)
      end

      it 'renders without the location row' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).not_to include('Location')
      end
    end

    context 'When a course has both study modes available' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
      let(:application_choice) { application_form.application_choices.first }
      let(:result) { render_inline(described_class.new(application_form:)) }

      before do
        application_choice.course.update!(study_mode: 'full_time_or_part_time')
      end

      it 'renders without the change link' do
        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when course is unavailable' do
      it 'renders without the unavailable course text' do
        application_form = build(:application_form)
        create(
          :application_choice,
          application_form:,
          course_option: build(:course_option, :no_vacancies),
        )

        result = render_inline(described_class.new(application_form:))

        expect(result.text).not_to include('it is not running')
      end
    end
  end

  context 'when a course choice is rejected' do
    it 'renders component with the status as rejected and displays the reason' do
      application_form = build(:application_form)
      create(
        :application_choice,
        application_form:,
        status: 'rejected',
        rejection_reason: 'Course full',
      )

      result = render_inline(described_class.new(application_form:, show_status: true))

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
        :offer_withdrawn,
        application_form:,
        offer_withdrawal_reason: 'Course full',
      )
    end

    it 'renders component with the status as Offer withdrawn and displays the reason' do
      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer withdrawn')
      expect(result.css('.govuk-summary-list__key').text).to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Course full')
    end

    it 'does not render the reason if an offer is subsequently made' do
      application_choice.offer!

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).not_to include('Course full')
    end
  end

  context 'when a course choice is awaiting provider decision' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision]) }

    it 'renders component with the status as awaiting decision' do
      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Awaiting decision')
    end

    it 'renders component with a withdraw link' do
      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.withdraw'))
      expect(result.css('.app-summary-card__actions a[data-action=withdraw]')).to be_present
    end
  end

  context 'when an offer has been made to a course choice' do
    it 'renders component with the status as offer when an offer has been made' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer])

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer received')
    end

    it 'renders component with view and respond to offer link' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer])

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.withdraw'))
      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.view_and_respond_to_offer'))
      expect(result.css('.app-summary-card__actions a[data-action=respond]')).to be_present
    end
  end

  context 'when an offer has been made for a different course' do
    let(:application_choice) do
      create(:application_choice,
             status: 'offer',
             course_option: create(:course_option, :full_time),
             current_course_option: create(:course_option, :part_time, course: create(:course, description: 'PGCE with QTS part time')))
    end
    let(:application_form) { create(:application_form, application_choices: [application_choice]) }

    it 'renders component with the status as offer and offered course details' do
      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Type')
      expect(result.css('.govuk-summary-list__value').to_html).to include('QTS with PGCE part time')
    end
  end

  context 'when an offer has been accepted i.e. pending conditions to a course choice' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions]) }

    it 'renders component with the status as accepted' do
      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer accepted')
    end

    it 'renders component with a withdraw link' do
      course_id = application_form.application_choices.first.id

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.withdraw'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_withdraw_path(course_id),
      )
    end
  end

  context 'when an offer has been declined to a course choice' do
    it 'renders component with the status as declined' do
      application_form = create_application_form_with_course_choices(statuses: %w[declined])

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer declined')
    end
  end

  context 'when an interview has been scheduled' do
    it 'renders the component with interview details' do
      application_choice = create(:application_choice, :with_completed_application_form, :interviewing)
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Interview')
    end
  end

  context 'when an interview has been cancelled' do
    it 'renders the component without interview details' do
      application_choice = create(:application_choice, :with_completed_application_form, :with_cancelled_interview)
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form:, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Interview')
    end
  end

  describe 'Visa sponsorship details' do
    context 'when the british candidate does not have the right to work' do
      it 'does NOT render a Visa sponsorship row' do
        application_form = create(
          :completed_application_form,
          first_nationality: 'British',
          second_nationality: nil,
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
        )
        create(:application_choice, application_form:)

        result = render_inline(described_class.new(application_form:, show_status: true))
        expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
      end
    end

    context 'when the candidate has the right to work' do
      it 'does NOT render a Visa sponsorship row' do
        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          second_nationality: nil,
          right_to_work_or_study: 'yes',
          recruitment_cycle_year: 2022,
        )
        create(:application_choice, application_form:)

        result = render_inline(described_class.new(application_form:, show_status: true))
        expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
      end
    end

    context 'when the candidate does not have the right to work' do
      it 'renders a Visa sponsorship row' do
        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          second_nationality: nil,
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
        )
        create(:application_choice, application_form:)

        result = render_inline(described_class.new(application_form:, show_status: true))
        expect(result.css('.govuk-summary-list__key').text).to include('Visa sponsorship')
      end
    end

    context 'when the candidate does not have the right to work and the course can sponsor a student visa' do
      it 'does NOT render a Visa sponsorship row' do
        provider = create(:provider)

        course_option = create(
          :course_option,
          course: create(
            :course,
            funding_type: 'fee',
            can_sponsor_student_visa: true,
            provider:,
          ),
        )

        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
          application_choices: [create(
            :application_choice,
            course_option:,
          )],
        )

        result = render_inline(described_class.new(application_form:))
        expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
      end
    end

    context 'when the candidate does not have the right to work and the course can NOT sponsor a student visa' do
      it 'renders a Visa sponsorship row' do
        provider = create(:provider)
        course_option = create(
          :course_option,
          course: create(
            :course,
            can_sponsor_student_visa: false,
            funding_type: 'fee',
            provider:,
          ),
        )

        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
          application_choices: [create(
            :application_choice,
            course_option:,
          )],
        )

        result = render_inline(described_class.new(application_form:))
        expect(result.css('.govuk-summary-list__key').text).to include('Visa sponsorship')
      end
    end

    context 'when the candidate does not have the right to work and the course can NOT sponsor a skilled worker visa on a salaried course' do
      it 'renders a Visa sponsorship row' do
        provider = create(:provider)
        course_option = create(
          :course_option,
          course: create(
            :course,
            can_sponsor_skilled_worker_visa: false,
            funding_type: 'salary',
            provider:,
          ),
        )

        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
          application_choices: [create(
            :application_choice,
            course_option:,
          )],
        )

        result = render_inline(described_class.new(application_form:))
        expect(result.css('.govuk-summary-list__key').text).to include('Visa sponsorship')
      end
    end

    context 'when the candidate does not have the right to work and the course can sponsor a skilled worker visa on a salaried course' do
      it 'renders a Visa sponsorship row' do
        provider = create(:provider)
        course_option = create(
          :course_option,
          course: create(
            :course,
            can_sponsor_skilled_worker_visa: true,
            funding_type: 'salary',
            provider:,
          ),
        )

        application_form = create(
          :completed_application_form,
          first_nationality: 'Indian',
          right_to_work_or_study: 'no',
          recruitment_cycle_year: 2022,
          application_choices: [create(
            :application_choice,
            course_option:,
          )],
        )

        result = render_inline(described_class.new(application_form:))
        expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
      end
    end

    context '2021 recruitment cycle' do
      context 'when the candidate does not have the right to work' do
        it 'does NOT render a Visa sponsorship row' do
          application_form = create(
            :completed_application_form,
            first_nationality: 'Indian',
            second_nationality: nil,
            right_to_work_or_study: 'no',
            recruitment_cycle_year: 2021,
          )
          create(:application_choice, application_form:)

          result = render_inline(described_class.new(application_form:, show_status: true))
          expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
        end
      end

      context 'when the candidate has the right to work' do
        it 'does NOT render a Visa sponsorship row' do
          application_form = create(
            :completed_application_form,
            first_nationality: 'Indian',
            second_nationality: nil,
            right_to_work_or_study: 'yes',
            recruitment_cycle_year: 2021,
          )
          create(:application_choice, application_form:)

          result = render_inline(described_class.new(application_form:, show_status: true))
          expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
        end
      end
    end
  end

  describe '#application_choices' do
    context "when one or more have an 'ACCEPTED_STATE'" do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions rejected]) }

      it 'returns only the application choices with ACCEPTED STATES' do
        component = described_class.new(application_form:, show_status: true, display_accepted_application_choices: true)

        expect(component.application_choices.count).to eq(1)
        expect(component.application_choices.first.status).to eq('pending_conditions')
      end
    end
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = build(:application_form)

    statuses.each do |status|
      create(
        :application_choice,
        application_form:,
        status:,
      )
    end

    application_form
  end
end
