require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationDashboardCourseChoicesComponent, type: :component do
  it 'renders component without a delete link and with a withdraw link' do
    application_form = create_application_form_with_course_choices(statuses: %w[unsubmitted])

    result = render_inline(described_class.new(application_form:, editable: false))

    expect(result.css('.app-summary-card__actions').text).not_to include(t('application_form.courses.delete'))
  end

  it 'renders a View application link' do
    application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])

    result = render_inline(described_class.new(application_form:, editable: false))

    expect(result.css('.app-summary-card__actions').text).to include('View application')
  end

  context 'When multiple courses available at a provider' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[unsubmitted]) }
    let(:application_choice) { application_form.application_choices.first }

    before do
      provider = application_form.application_choices.first.provider
      create(:course, provider:, study_mode: :full_time)
    end

    it 'renders without the course choice change link' do
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
        :application_choice,
        application_form:,
        course_option: create(:course_option, :no_vacancies),
      )

      result = render_inline(described_class.new(application_form:, editable: false))

      expect(result.text).not_to include('it is not running')
    end
  end

  context 'a rejected course choice' do
    let!(:application_form) { create(:application_form) }
    let!(:application_choice) do
      create(
        :application_choice,
        application_form:,
        status: 'rejected',
        rejection_reason: 'Course full',
      )
    end

    it 'does render the rejection feedback button' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))
      expect(result.css('.govuk-summary-list__row').text).to include('Is this feedback helpful?')
      expect(result).to summarise(key: 'Status', value: 'Unsuccessful')
      expect(result).to summarise(key: 'Feedback', value: 'Course full Is this feedback helpful? Yes No')
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
      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )
      expect(rendered_component).to summarise(key: 'Status', value: 'Offer withdrawn')
      expect(rendered_component).to summarise(key: 'Reason for offer withdrawal', value: 'Course full')
    end

    it 'does not render the reason if an offer is subsequently made' do
      application_choice.offer!

      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )
      expect(rendered_component).not_to summarise(
        key: 'Reason for offer withdrawal',
        value: 'Course full',
      )
    end
  end

  context 'when a course choice is awaiting provider decision' do
    let(:application_form) { create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision]) }

    it 'renders component with the status as awaiting decision' do
      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )

      expect(rendered_component).to summarise(key: 'Status', value: 'Awaiting decision Application submitted today. If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.')
    end

    it 'renders component with a withdraw link' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).to include('Withdraw this application')
    end
  end

  context 'when an offer has been made to a course choice' do
    it 'renders component with the status as offer when an offer has been made' do
      conditions = [build(:text_condition, description: 'DBS check'), build(:text_condition, description: 'Get a haircut')]
      application_form = create_application_form_with_course_choices(statuses: %w[offer])
      application_form.update(recruitment_cycle_year: 2023)
      application_choice = application_form.application_choices.first
      create(:offer, application_choice:, conditions:)

      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )
      expect(rendered_component).to summarise(
        key: 'Status',
        value: "Offer received What to do if you are unable to start training in #{application_choice.course_option.course.start_date.to_fs(:month_and_year)} You can defer your offer and start your course a year later. Contact #{application_choice.course_option.course.provider.name} to ask if it is possible to defer, this will not affect your existing offer. If your provider agrees, you will need to accept the offer first.",
      )
      expect(rendered_component).to summarise(
        key: 'Conditions',
        value: 'DBS check Get a haircut Contact the provider to find out more about these conditions. They’ll confirm your place once you have met the conditions and they’ve checked your references.',
      )
    end

    it 'shows some generic conditions copy if the offer is unconditional' do
      offer = create(:unconditional_offer)

      rendered_component = render_inline(
        described_class.new(
          application_form: offer.application_choice.application_form,
          editable: false,
          show_status: true,
        ),
      )
      expect(rendered_component).to summarise(
        key: 'Conditions',
        value: 'Contact the provider to find out more about any conditions. They’ll confirm your place once you have met any conditions and they’ve checked your references.',
      )
    end

    it 'renders component with the respond to offer link and message about waiting for providers to respond' do
      application_form = Satisfactory.root
        .add(:application_form)
        .with(:application_choice).which_is(:offered)
        .and(:application_choice).which_is(:awaiting_provider_decision)
        .create[:application_form].first

      result = render_inline(
        described_class.new(
          application_form:,
          editable: false,
          show_status: true,
        ),
      )

      expect(result).to have_css('.govuk-summary-list__value', text: 'Respond to offer')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(
          application_form.application_choices.offer.first,
        ),
      )
    end

    it 'renders component with the respond to offer link and message about waiting for providers to respond', time: mid_cycle do
      application_form = Satisfactory.root
        .add(:application_form)
        .with(:application_choice).which_is(:offered)
        .and(:application_choice).which_is(:awaiting_provider_decision)
        .create[:application_form].first

      result = render_inline(
        described_class.new(
          application_form:,
          editable: false,
          show_status: true,
        ),
      )

      expect(result).to have_css('.govuk-summary-list__value', text: 'Respond to offer')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(
          application_form.application_choices.offer.first,
        ),
      )
    end

    it 'renders component with the respond to offer link and deadline message', time: 3.months.ago do
      application_form = Satisfactory.root
        .add(:application_form)
        .with(:application_choice).which_is(:offered)
        .and(:application_choice).which_is(:rejected)
        .create[:application_form].first

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).not_to include('Respond to application')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(
          application_form.application_choices.offer.first.id,
        ),
      )
    end
  end

  context 'when an offer has been accepted i.e. pending conditions to a course choice' do
    let(:application_choice) { create(:application_choice, :accepted) }
    let(:application_form) { application_choice.application_form }

    it 'renders component with the status as accepted' do
      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).to include('Status')
      expect(result.css('.govuk-summary-list__value').to_html).to include('Offer accepted')
    end

    it 'renders component with a withdraw link' do
      course_id = application_form.application_choices.first.id

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__value').text).to include('Withdraw this application')
      expect(result.css('.govuk-summary-list__value a')[0].attr('href')).to include(
        Rails.application.routes.url_helpers.candidate_interface_withdrawal_reasons_level_one_reason_new_path(course_id),
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

  context 'when an interview has been cancelled and the status is withdrawn' do
    it 'renders the component without interview details' do
      application_choice = create(
        :application_choice,
        :with_completed_application_form,
        :with_cancelled_interview,
      )
      application_choice.withdrawn!
      application_form = application_choice.application_form

      result = render_inline(described_class.new(application_form:, editable: false, show_status: true))

      expect(result.css('.govuk-summary-list__key').text).not_to include('Interview')
    end
  end

  context "when there's an offer with a standard SKE condition" do
    let(:application_choice) { create(:application_choice, :offered, offer:, course_option:) }
    let(:application_form) { application_choice.application_form }
    let(:offer) { create(:offer, :with_ske_conditions) }
    let(:course_option) { build(:course_option, course:) }
    let(:course) { build(:course, course_subjects:) }
    let(:course_subjects) { [build(:course_subject, subject:)] }
    let(:subject) { build(:subject, :non_language) } # rubocop:disable RSpec/SubjectDeclaration

    it 'renders the component with SKE conditions' do
      render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      ) do |rendered_component|
        application_choice.reload

        expect(application_choice.offer.ske_conditions.count).to eq(1)
        ske_condition = application_choice.offer.ske_conditions.first

        [
          /#{ske_condition.length} week #{ske_condition.subject} course/,
          /because #{I18n.t("candidate_interface.offer.ske_reasons.#{ske_condition.reason}", degree_subject: ske_condition.subject)}/,
          /before your teacher training starts in #{course.start_date.to_fs(:month_and_year)}/,
        ].each do |value|
          expect(rendered_component).to summarise(key: 'Subject knowledge enhancement course', value:)
        end
      end
    end
  end

  context 'when there is an offer with reference condition without description' do
    let(:application_form) { application_choice.application_form }
    let(:application_choice) { create(:application_choice, :offered, offer:) }
    let(:offer) { create(:offer, conditions: [build(:reference_condition, description: nil)]) }

    it 'renders the references section with a default content' do
      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )
      expect(rendered_component).to summarise(
        key: 'References',
        value: "The provider will confirm your place once they've checked your references.",
      )
    end
  end

  context 'when there is an offer that has been withdrawn' do
    let(:application_form) { application_choice.application_form }
    let(:application_choice) { create(:application_choice, :offer_withdrawn) }

    it 'renders the references section with a default content' do
      rendered_component = render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      )
      expect(rendered_component).not_to summarise(
        key: 'References',
        value: "The provider will confirm your place once they've checked your references.",
      )
    end
  end

  context 'when there is an offer with reference condition with description' do
    let(:application_form) { application_choice.application_form }
    let(:application_choice) { create(:application_choice, :offered, offer:) }
    let(:offer) { create(:offer, conditions: [build(:reference_condition, description: 'You need to provide 6 references')]) }

    it 'renders the references section with a description' do
      render_inline(
        described_class.new(application_form:, editable: false, show_status: true),
      ) do |rendered_component|
        expect(rendered_component).to summarise(key: 'References', value: "#{offer.provider.name} said: You need to provide 6 references")
      end
    end
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = create(:application_form)

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
