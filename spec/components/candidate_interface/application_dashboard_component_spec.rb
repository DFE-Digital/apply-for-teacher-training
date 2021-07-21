require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationDashboardComponent do
  describe '#title' do
    it 'renders the correct title for an application with a single application choice' do
      application_form = create_application_form_with_course_choices(statuses: %w[awaiting_provider_decision])

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include('Your application')
    end

    it 'renders the correct title for an application with multiple application choices' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[awaiting_provider_decision rejected],
      )

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include('Your applications')
    end

    it 'renders the correct title for an apply again application' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[awaiting_provider_decision],
        apply_again: true,
      )

      render_result = render_inline(described_class.new(application_form: application_form))

      expect(render_result.text).to include('Your applications')
    end
  end

  describe 'subtitle' do
    it 'does not render the submitted on message' do
      application_form = create_application_form_with_course_choices(
        statuses: %w[awaiting_provider_decision rejected],
      )
      render_result = render_inline(described_class.new(application_form: application_form))
      expect(render_result.text).not_to include('Application submitted on')
    end
  end

  context 'when it is after the apply1 deadline' do
    around do |example|
      Timecop.freeze(CycleTimetable.apply_1_deadline + 1.day) do
        example.run
      end
    end

    context 'the application has ended without success' do
      it 'renders the deadline banner' do
        application_form = create_application_form_with_course_choices(
          statuses: %w[rejected],
        )
        render_result = render_inline(described_class.new(application_form: application_form))
        expect(render_result.text).to include("The deadline for applying to courses starting in the #{CycleTimetable.cycle_year_range} academic year is 6pm on #{CycleTimetable.apply_2_deadline.to_s(:govuk_date)}")
      end
    end

    context 'the application was successful' do
      it 'does not render the deadline banner' do
        application_form = create_application_form_with_course_choices(
          statuses: %w[recruited],
        )
        render_result = render_inline(described_class.new(application_form: application_form))
        expect(render_result.text).not_to include("The deadline for applying to courses starting in the #{CycleTimetable.cycle_year_range} academic year is 6pm on #{CycleTimetable.apply_2_deadline.to_s(:govuk_date)}")
      end
    end
  end

  def create_application_form_with_course_choices(statuses:, apply_again: false)
    previous_application_form = apply_again ? create_application_form_with_course_choices(statuses: %w[rejected]) : nil

    application_form = create(
      :completed_application_form,
      submitted_at: 2.days.ago,
      previous_application_form: previous_application_form,
      phase: apply_again ? :apply_2 : :apply_1,
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
