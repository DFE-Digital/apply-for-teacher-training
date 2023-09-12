require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoicesReviewComponent, :mid_cycle, type: :component do
  context 'when course choices are editable' do
    let(:application_form) do
      create_application_form_with_course_choices(statuses: %w[unsubmitted])
    end

    it 'renders component with correct values for a course' do
      application_choice = application_form.application_choices.first
      render_inline(described_class.new(application_form:)) do |rendered_component|
        expect(rendered_component).to summarise(
          key: 'Course',
          value: "#{application_choice.course.name} (#{application_choice.course.code})",
        )

        expect(rendered_component).to summarise(
          key: 'Course length',
          value: '1 year',
        )

        expect(rendered_component).to summarise(
          key: 'Type',
          value: application_choice.course.description,
        )

        expect(rendered_component).to summarise(
          key: 'Date course starts',
          value: application_choice.course.start_date.to_fs(:month_and_year),
        )

        expect(rendered_component).to have_css('.app-summary-card__title', text: application_choice.provider.name)

        expect(rendered_component).to have_link("#{application_choice.course.name} (#{application_choice.course.code})", href: "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
      end
    end

    it 'does not show the application number' do
      render_inline(described_class.new(application_form:)) do |rendered_component|
        expect(rendered_component).not_to include 'Application number'
      end
    end

    context 'when Find is down' do
      it 'removes the link to Find' do
        travel_temporarily_to(CycleTimetable.find_closes.end_of_day + 1.hour) do
          application_choice = application_form.application_choices.first
          result = render_inline(described_class.new(application_form:))

          expect(result.css('.govuk-summary-list__value').to_html).to include("#{application_choice.course.name} (#{application_choice.course.code})")
          expect(result.css('a').to_html).not_to include("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{application_choice.provider.code}/#{application_choice.course.code}")
        end
      end
    end

    context 'When multiple courses available at a provider' do
      let(:application_choice) { application_form.application_choices.first }

      before do
        provider = application_form.application_choices.first.provider
        create(:course, :open_on_apply, provider:, study_mode: :full_time)
      end

      it 'renders the course row with change link' do
        result = render_inline(described_class.new(application_form:))
        change_location_link = result.css('.govuk-summary-list__actions')[0].text.strip

        expect(change_location_link).to eq("Change course choice for #{application_choice.course.name_and_code}")
      end
    end

    context 'When only one course available at a provider' do
      let(:application_choice) { application_form.application_choices.first }

      it 'renders the course row without change link' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.app-summary-card__actions').text).not_to include("Change course for #{application_choice.course.name_and_code}")
      end
    end

    context 'When a course has both study modes available' do
      let(:application_choice) { application_form.application_choices.first }
      let(:result) { render_inline(described_class.new(application_form:)) }

      before do
        application_choice.course.update!(study_mode: 'full_time_or_part_time')
      end

      it 'renders study mode values' do
        expect(result.css('.govuk-summary-list__key').text).to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).to include(application_choice.current_course_option.study_mode.humanize.to_s)
      end

      it 'renders the study mode change link' do
        expect(result.css('.govuk-summary-list__actions').text).to include(
          "Change study mode for #{application_choice.course.name_and_code}",
        )
      end
    end

    context 'When a course has one available study mode' do
      let(:application_choice) { application_form.application_choices.first }

      before do
        application_choice.course.update!(study_mode: %w[full_time part_time].sample)
      end

      it 'renders without the study mode row or change link' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__key').text).not_to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).not_to include(application_choice.current_course_option.study_mode.humanize.to_s)
        expect(result.css('.app-summary-card__actions').text).not_to include("Change study mode for #{application_choice.course.name_and_code}")
      end
    end

    it 'renders component with correct values for a location' do
      application_choice = application_form.application_choices.first
      render_inline(described_class.new(application_form:)) do |rendered_component|
        expect(rendered_component).to summarise(
          key: 'Location',
          value: "#{application_choice.site.name} #{application_choice.site.full_address}",
        )
      end
    end

    it 'renders component along with a delete link for each course' do
      application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

      result = render_inline(described_class.new(application_form:))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.delete'))
      expect(result.css('.app-summary-card__actions a[data-action=delete]')).to be_present
    end

    it 'renders component with correct values for multiple courses' do
      result = render_inline(described_class.new(application_form:))

      application_form.application_choices.each do |application_choice|
        expect(result.css('.app-summary-card__title').text).to include(application_choice.provider.name)
      end
    end

    context 'when course choice is single site' do
      it 'renders without the "Change" location links' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'When a course has a required degree grade' do
      let(:application_choice) { application_form.application_choices.first }
      let(:result) { render_inline(described_class.new(application_form:)) }

      before do
        application_choice.course.update!(degree_grade: 'two_two')
      end

      it 'renders the degree required row' do
        expect(result.text).to include('2:2 degree or higher (or equivalent)')
      end
    end

    context 'When a candidate has a missing gcse' do
      let(:application_choice) { application_form.application_choices.first }
      let(:application_qualification) { build(:gcse_qualification, :missing_and_currently_completing, subject: 'english', currently_completing_qualification: false) }
      let(:result) { render_inline(described_class.new(application_form:)) }

      before do
        application_choice.application_form.application_qualifications << application_qualification
        application_choice.course.update!(accept_gcse_equivalency: true, accept_english_gcse_equivalency: true, accept_pending_gcse: false)
      end

      it 'renders the GCSE required row' do
        expect(result.text).to include('GCSE requirements')
        expect(result.text).to include('This provider will accept equivalency tests in English')
      end
    end

    context 'When a candidate has a pending gcse' do
      let(:application_choice) { application_form.application_choices.first }
      let(:application_qualification) { build(:gcse_qualification, :missing_and_currently_completing) }
      let(:result) { render_inline(described_class.new(application_form:)) }

      before do
        application_choice.application_form.application_qualifications << application_qualification
        application_choice.course.update!(accept_gcse_equivalency: false, accept_pending_gcse: true)
      end

      it 'renders the GCSE required row' do
        expect(result.text).to include('GCSE requirements')
        expect(result.text).to include('This provider will consider candidates with pending GCSEs')
      end
    end

    context 'when there are multiple site options for course' do
      before do
        create(:course_option, course: application_form.application_choices.first.course)
      end

      it 'renders the correct text for "Change" location links' do
        application_choice = application_form.application_choices.first
        result = render_inline(described_class.new(application_form:))
        expect(result.css('.govuk-summary-list__actions').text).to include(
          "Change location for #{application_choice.course.name_and_code}",
        )
      end
    end

    context 'when other site option is a different study mode for course' do
      before do
        build(:course_option, course: application_form.application_choices.first.course, study_mode: 'part_time')
      end

      it 'renders without the "Change" location links' do
        result = render_inline(described_class.new(application_form:))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    it 'renders with the unavailable course text when course is unavailable' do
      application_form = build(:application_form)
      create(
        :application_choice,
        application_form:,
        course_option: build(:course_option,
                             course: build(:course, :unavailable)),
      )

      render_inline(described_class.new(application_form:, editable: true))

      expect(page).to have_text('it is not running')
    end

    it 'renders the guidance when the course is not taking applications yet' do
      application_form = build(:application_form)
      create(
        :application_choice,
        application_form:,
        course_option: build(:course_option,
                             course: build(:course, :open_on_apply, applications_open_from: 1.day.from_now)),
      )

      render_inline(described_class.new(application_form:))
      expect(page).to have_text("You‘ll be able to apply for this course from #{1.day.from_now.to_fs(:govuk_date)}")
    end

    describe 'guidance when course cannot be attended' do
      it 'renders the guidance when the course is full' do
        application_form = build(:application_form)
        create(
          :application_choice,
          application_form:,
          course_option: build(:course_option,
                               :no_vacancies,
                               course: build(:course, :open_on_apply)),
        )

        render_inline(described_class.new(application_form:))
        expect(page).to have_text('You cannot apply to this course as there are no places left on it')
      end

      it 'renders the guidance when the site is full' do
        application_form = build(:application_form)
        course = build(:course, :open_on_apply)

        create(
          :application_choice,
          application_form:,
          course_option: build(:course_option,
                               :no_vacancies,
                               course:),
        )

        create(:course_option, course:)

        render_inline(described_class.new(application_form:))
        expect(page).to have_text('You cannot apply to this course as the chosen location is full')
      end

      it 'renders the guidance when the site is invalid' do
        application_form = build(:application_form)
        course = build(:course, :open_on_apply)

        create(
          :application_choice,
          application_form:,
          course_option: build(:course_option,
                               course:,
                               site_still_valid: false),
        )

        create(:course_option, course:)

        render_inline(described_class.new(application_form:))
        expect(page).to have_text('You cannot apply to this course as the chosen location is full')
      end

      it 'renders the guidance when the study mode is full' do
        application_form = build(:application_form)
        course = build(:course, :open_on_apply)
        course_option = build(:course_option,
                              :no_vacancies,
                              :full_time,
                              course:)

        create(
          :application_choice,
          application_form:,
          course_option:,
        )

        create(:course_option, :part_time, course:, site: course_option.site)

        render_inline(described_class.new(application_form:))
        expect(page).to have_text('You cannot apply to this course as the chosen study mode is full')
      end
    end
  end

  context 'when course choices are not editable' do
    it 'renders component without a delete link and with a withdraw link' do
      application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
    end

    it 'shows the application number' do
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])
      render_inline(described_class.new(application_form:, editable: false)) do |rendered_component|
        expect(rendered_component).to include 'Application number'
        expect(rendered_component).to include application_form.application_choices.first.id.to_s
      end
    end

    context 'When multiple courses available at a provider' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
      let(:application_choice) { application_form.application_choices.first }

      before do
        provider = application_form.application_choices.first.provider
        build(:course, :open_on_apply, provider:, study_mode: :full_time)
      end

      it 'renders without the course choice change link' do
        result = render_inline(described_class.new(application_form:, editable: false))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'when there are multiple site options for course' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }

      before do
        build(:course_option, course: application_form.application_choices.first.course)
      end

      it 'renders without a "Change" location links' do
        result = render_inline(described_class.new(application_form:, editable: false))

        expect(result.css('.govuk-summary-list__actions').text).not_to include('Change')
      end
    end

    context 'When a course has both study modes available' do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
      let(:application_choice) { application_form.application_choices.first }
      let(:result) { render_inline(described_class.new(application_form:, editable: false)) }

      before do
        application_choice.course.update!(study_mode: 'full_time_or_part_time')
      end

      it 'renders study mode values' do
        expect(result.css('.govuk-summary-list__key').text).to include('Full time or part time')
        expect(result.css('.govuk-summary-list__value').text).to include(application_choice.current_course_option.study_mode.humanize.to_s)
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

        result = render_inline(described_class.new(application_form:, editable: false))

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

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

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
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer withdrawn')
      expect(result.css('.govuk-summary-list__key').text).to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Course full')
    end

    it 'does not render the reason if an offer is subsequently made' do
      application_choice.offer!

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Reason for offer withdrawal')
      expect(result.css('.govuk-summary-list__value').to_html).not_to include('Course full')
    end
  end

  context 'when a course choice is awaiting provider decision' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision]) }

    it 'renders component with the status as awaiting decision' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Awaiting decision')
    end

    it 'renders component with a withdraw link' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.withdraw'))
      expect(result.css('.app-summary-card__actions a[data-action=withdraw]')).to be_present
    end
  end

  context 'when an offer has been made to a course choice' do
    it 'renders component with the status as offer when an offer has been made' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer])

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer received')
    end

    it 'renders component with view and respond to offer link' do
      application_form = create_application_form_with_course_choices(statuses: %w[offer])

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

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
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Type')
      expect(result.css('.govuk-summary-list__value').to_html).to include('PGCE with QTS part time')
    end
  end

  context 'when an offer has been accepted i.e. pending conditions to a course choice' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions]) }

    it 'renders component with the status as accepted' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer accepted')
    end

    it 'renders component with a withdraw link' do
      course_id = application_form.application_choices.first.id

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.app-summary-card__actions').text).to include(t('application_form.courses.withdraw'))
      expect(result.css('.app-summary-card__actions a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_withdraw_path(course_id),
      )
    end
  end

  context 'when an offer has been declined to a course choice' do
    it 'renders component with the status as declined' do
      application_form = create_application_form_with_course_choices(statuses: %w[declined])

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer declined')
    end
  end

  context 'when an interview has been scheduled' do
    it 'renders the component with interview details' do
      application_choice = create(:application_choice, :with_completed_application_form, :interviewing)
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Interview')
    end
  end

  context 'when an interview has been cancelled' do
    it 'renders the component without interview details' do
      application_choice = create(:application_choice, :with_completed_application_form, :with_cancelled_interview)
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

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

        result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
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

        result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
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

        result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
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

          result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
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

          result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
          expect(result.css('.govuk-summary-list__key').text).not_to include('Visa sponsorship')
        end
      end
    end
  end

  describe '#application_choices' do
    context "when one or more have an 'ACCEPTED_STATE'" do
      let(:application_form) { create_application_form_with_course_choices(statuses: %w[pending_conditions rejected]) }

      it 'returns only the application choices with ACCEPTED STATES' do
        component = described_class.new(application_form:, editable: false, show_status: true, display_accepted_application_choices: true)

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
