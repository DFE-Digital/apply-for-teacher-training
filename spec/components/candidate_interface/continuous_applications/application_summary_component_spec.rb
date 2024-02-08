require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::ApplicationSummaryComponent, type: :component do
  subject(:result) do
    render_inline(described_class.new(application_choice:))
  end

  let(:application_choice) do
    create(:application_choice, :awaiting_provider_decision)
  end
  let(:actions) { result.css('.govuk-summary-card__actions').text }
  let(:links) { result.css('a').map(&:text).join(' ') }

  it 'renders a View application link' do
    expect(actions).to include('View application')
  end

  it 'renders the course information' do
    expect(result.text).to include(application_choice.current_course.name_and_code)
  end

  context 'when application is unsubmitted' do
    let(:application_choice) do
      create(:application_choice, :unsubmitted)
    end

    it 'renders component with delete link' do
      expect(actions).to include(t('application_form.continuous_applications.courses.delete'))
    end

    it 'renders the status' do
      expect(result.text).to include('StatusDraft')
    end

    it 'renders the continue application link' do
      expect(links).to include('Continue application')
    end

    context 'when application course is not full' do
      it 'renders the `View application` link without the course full info and `Change` link' do
        expect(result.text).not_to include('You cannot apply to this course as there are no places left on it')
        expect(result.text).not_to include('You need to either remove or change this course choice')
        expect(result.text).not_to include('may be able to recommend an alternative course')
        expect(actions).not_to include('View application')
        expect(links).not_to include('Change')
      end
    end

    context 'when application course is full' do
      let(:course) { create(:course, :with_no_vacancies) }

      context 'when unsubmitted' do
        let(:application_choice) { create(:application_choice, :unsubmitted, course:) }

        it 'renders the course full info and `Change` link without the `View application` link' do
          expect(result).to have_css('.govuk-inset-text')
          expect(result.text).to include('You cannot apply to this course as there are no places left on it')
          expect(result.text).to include('You need to either remove or change this course choice')
          expect(result.text).to include("#{application_choice.course.provider.name} may be able to recommend an alternative course.")
          expect(actions).not_to include('View application')
          expect(links).to include('Change')
        end
      end

      context 'when submitted' do
        let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course:) }

        it 'renders the course full info and `Change` link without the `View application` link' do
          expect(result).to have_no_css('.govuk-inset-text')
          expect(result.text).not_to include('You cannot apply to this course as there are no places left on it')
          expect(result.text).not_to include('You need to either remove or change this course choice')
          expect(result.text).not_to include("#{application_choice.course.provider.name} may be able to recommend an alternative course.")
          expect(actions).to include('Withdraw')
          expect(links).not_to include('Change')
        end
      end
    end
  end

  context 'when application is offered' do
    let(:application_choice) do
      create(:application_choice, :offered)
    end

    it 'renders component without delete link' do
      expect(actions).not_to include(t('application_form.continuous_applications.courses.delete'))
    end

    it 'renders the status' do
      expect(result.text).to include('StatusOffer received')
    end

    it 'does not show the decline by default message' do
      expect(result.text).not_to include('You do not need to respond to this offer yet')
    end

    it 'renders component with the respond to offer link and message about waiting for providers to respond' do
      result = render_inline(
        described_class.new(
          application_choice:,
        ),
      )

      expect(result).to have_css('.govuk-summary-list__value', text: 'Respond to offer')
      expect(result.css('.govuk-summary-list__value a').map { |link| link.attr('href') }).to include(
        Rails.application.routes.url_helpers.candidate_interface_offer_path(application_choice),
      )
    end
  end

  context 'an interview course choice' do
    let!(:application_choice) do
      create(
        :application_choice,
        :interviewing,
      )
    end

    it 'does render the interview booking component' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.css('.govuk-summary-list__row').text).to include('Interviewing')
      expect(result.css('.govuk-summary-list__row').text).to include('You have an interview scheduled for')
      expect(result.css('.govuk-summary-list__row').text).to include('The provider will send more details about the interview by email.')
    end
  end

  context 'a rejected course choice' do
    let!(:application_form) { create(:application_form) }
    let!(:application_choice) do
      create(
        :application_choice,
        :rejected,
        application_form:,
        rejection_reason: 'Course full',
      )
    end

    it 'does render the rejection feedback button' do
      result = render_inline(described_class.new(application_choice:))
      expect(result.css('.govuk-summary-list__row').text).to include('Is this feedback helpful?')
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
        described_class.new(application_choice:),
      )
      expect(rendered_component).to summarise(key: 'Status', value: 'Offer withdrawn')
      expect(rendered_component).to summarise(key: 'Reason for offer withdrawal', value: 'Course full')
    end

    it 'does not render the reason if an offer is subsequently made' do
      application_choice.offer!

      rendered_component = render_inline(
        described_class.new(application_choice:),
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
        described_class.new(application_choice:),
      )

      expect(rendered_component).to summarise(key: 'Status', value: 'Awaiting decision Application submitted today. If you do not receive a response from this training provider, you can withdraw this application and apply to another provider.')
    end

    it 'renders component with a withdraw link' do
      result = render_inline(described_class.new(application_choice:))

      expect(result.css('.govuk-summary-card__action').text).to include('Withdraw')
    end
  end

  context 'when there is an offer with a standard SKE condition' do
    let(:application_choice) { create(:application_choice, :offered, offer:, course_option:) }
    let(:application_form) { application_choice.application_form }
    let(:offer) { create(:offer, :with_ske_conditions) }
    let(:course_option) { build(:course_option, course:) }
    let(:course) { build(:course, course_subjects:) }
    let(:course_subjects) { [build(:course_subject, subject:)] }
    let(:subject) { build(:subject, :non_language) } # rubocop:disable RSpec/SubjectDeclaration

    it 'renders the component with SKE conditions' do
      render_inline(
        described_class.new(application_choice:),
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
        described_class.new(application_choice:),
      )
      expect(rendered_component).to summarise(
        key: 'References',
        value: "The provider will confirm your place once they've checked your references.",
      )
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
        described_class.new(application_choice:),
      )
      expect(rendered_component).to summarise(
        key: 'Status',
        value: "Offer received What to do if you’re unable to start training in #{application_choice.course_option.course.start_date.to_fs(:month_and_year)} You can defer your offer and start your course a year later. Contact #{application_choice.course_option.course.provider.name} to ask if it’s possible to defer, this will not affect your existing offer. If your provider agrees, you’ll need to accept the offer first.",
      )
      expect(rendered_component).to summarise(
        key: 'Conditions',
        value: 'DBS check Get a haircut Contact the provider to find out more about these conditions. They’ll confirm your place once you’ve met the conditions and they’ve checked your references.',
      )
    end

    it 'shows some generic conditions copy if the offer is unconditional' do
      offer = create(:unconditional_offer)

      rendered_component = render_inline(
        described_class.new(
          application_choice: offer.application_choice,
        ),
      )
      expect(rendered_component).to summarise(
        key: 'Conditions',
        value: 'Contact the provider to find out more about any conditions. They’ll confirm your place once you’ve met any conditions and they’ve checked your references.',
      )
    end
  end

  def create_application_form_with_course_choices(statuses:)
    application_form = create(:application_form)

    statuses.each do |status|
      create(
        :application_choice,
        application_form:,
        status:,
        decline_by_default_at: status.to_sym == :offer ? 5.days.from_now : nil,
      )
    end

    application_form
  end
end
