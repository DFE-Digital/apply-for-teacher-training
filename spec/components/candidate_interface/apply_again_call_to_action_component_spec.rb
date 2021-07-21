require 'rails_helper'

RSpec.describe CandidateInterface::ApplyAgainCallToActionComponent do
  context 'it is mid cycle' do
    around do |example|
      Timecop.freeze(CycleTimetable.apply_opens + 1.day) do
        example.run
      end
    end

    it 'renders nothing if the application if from an earlier recruitment cycle' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[rejected],
        attrs: { recruitment_cycle_year: RecruitmentCycle.previous_year },
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to be_blank
    end

    it 'displays correct title when one application is declined' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[declined rejected],
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to include('You’ve declined your offer')
    end

    it 'displays correct title when multiple applications have been declined' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[declined declined rejected],
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to include('You’ve declined all of your offers')
    end

    it 'displays correct title when one application is withdrawn' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[withdrawn rejected],
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to include('You’ve withdrawn your application')
    end

    it 'displays correct title when multiple applications have been withdrawn' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[withdrawn withdrawn rejected],
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to include('You’ve withdrawn your applications')
    end

    it 'displays correct default title when no applications were withdrawn or declined' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[conditions_not_met rejected offer_withdrawn],
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to include('Your applications were unsuccessful')
    end
  end

  context 'it is not mid cycle' do
    around do |example|
      Timecop.freeze(CycleTimetable.apply_2_deadline + 1.day) do
        example.run
      end
    end

    it 'renders nothing' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[rejected],
        attrs: { recruitment_cycle_year: RecruitmentCycle.current_year },
      )
      result = render_inline(described_class.new(application_form: application_form))
      expect(result.text).to be_blank
    end
  end

  def create_application_form_with_course_choices(statuses:, apply_again: false, attrs: {})
    previous_application_form = apply_again ? create_application_form_with_course_choices(statuses: %w[rejected]) : nil

    application_form = create(
      :completed_application_form,
      attrs.merge(
        submitted_at: 2.days.ago,
        previous_application_form: previous_application_form,
        phase: apply_again ? :apply_2 : :apply_1,
      ),
    )
    statuses.map do |status|
      create(
        :application_choice,
        application_form: application_form,
        status: status,
      )
    end

    application_form
  end
end
