require 'rails_helper'

RSpec.describe CandidateInterface::OffersCallToActionComponent do
  before do
    TestSuiteTimeMachine.travel_permanently_to(2021, 3, 24, 12)
  end

  it 'renders nothing if the application has no offers' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[awaiting_provider_decision withdrawn rejected],
    )
    result = render_inline(described_class.new(application_form:))
    expect(result.text).to be_blank
  end

  it 'displays correct title and message when there is a single offer' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer withdrawn rejected],
    )
    result = render_inline(described_class.new(application_form:))
    expect(result.text).to include('Congratulations on your offer')
    expect(result.text).to include('You have 193 days (until 3 October 2021) to respond. If you do not respond, your offer will be automatically declined.')
  end

  it 'displays correct title and message when there are multiple offers' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer offer rejected],
    )
    result = render_inline(described_class.new(application_form:))
    expect(result.text).to include('Congratulations on your offers')
    expect(result.text).to include('You have 193 days (until 3 October 2021) to respond. If you do not respond, your offers will be automatically declined.')
  end

  def create_application_form_with_course_choices(statuses:, apply_again: false)
    previous_application_form = apply_again ? create_application_form_with_course_choices(statuses: %w[rejected]) : nil

    application_form = create(
      :completed_application_form,
      submitted_at: 2.days.ago,
      previous_application_form:,
      phase: apply_again ? :apply_2 : :apply_1,
    )
    statuses.map do |status|
      create(
        :application_choice,
        application_form:,
        status:,
      )
    end

    application_form
  end
end
