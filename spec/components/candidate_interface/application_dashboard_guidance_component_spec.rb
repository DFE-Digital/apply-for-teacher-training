require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationDashboardGuidanceComponent do
  it 'displays correct message when multiple application choices are `awaiting_provider_decision`' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[awaiting_provider_decision awaiting_provider_decision rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Your applications have been submitted and are with the training providers')
  end

  it 'displays correct message when a single application choice is `awaiting_provider_decision`' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[awaiting_provider_decision],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Your application has been submitted and is with the training provider')
  end

  it 'displays correct message when a single application choice is in `offer` status and another is `awaiting_provider_decision`' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer awaiting_provider_decision],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('One of your training providers has made a decision on your application')
  end

  it 'displays correct message when multiple application choices are in `offer` status and another is `awaiting_provider_decision`' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer offer awaiting_provider_decision],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('2 of your training providers have made a decision on your application')
  end

  it 'displays correct message when an offer has been accepted' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[declined pending_conditions rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include("You’ve accepted the offer from #{application_form.application_choices.pending_conditions.first.provider.name}")
  end

  it 'displays correct message when an offer has been deferred' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[declined offer_deferred rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('You’ve chosen to defer your course')
  end

  it 'displays correct message when conditions have been met' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[declined recruited rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Congratulations on joining your teacher training course')
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
