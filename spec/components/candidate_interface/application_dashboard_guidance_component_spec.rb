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
      statuses: %w[awaiting_provider_decision rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Your application has been submitted and is with the training provider')
  end

  def create_application_form_with_course_choices(statuses:, apply_again: false)
    previous_application_form = apply_again ? create_application_form_with_course_choices(statuses: %w[rejected]) : nil
 
    application_form = create(
      :completed_application_form,
      submitted_at: 2.days.ago,
      previous_application_form: previous_application_form,
      phase: apply_again ? :apply_2 : :apply_1
    )
    application_choices = statuses.map do |status|
      create(
        :application_choice,
        application_form: application_form,
        status: status,
      )
    end

    application_form
  end
end
