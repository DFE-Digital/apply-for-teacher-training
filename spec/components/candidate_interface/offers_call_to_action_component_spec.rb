require 'rails_helper'

RSpec.describe CandidateInterface::OffersCallToActionComponent do
  around do |example|
    Timecop.freeze(2021, 3, 24, 12) do
      example.run
    end
  end

  it 'renders nothing if the application has no offers' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[awaiting_provider_decision withdrawn rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to be_blank
  end

  it 'displays correct title and message when there is a single offer' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer withdrawn rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Congratulations on your offer')
    expect(result.text).to include('You have 10 days (until 3 April 2021) to respond. If you do not respond, your offer will automatically be declined.')
  end

  it 'displays correct title and message when there are multiple offers' do
    application_form = create_application_form_with_course_choices(
      statuses: %w[offer offer rejected],
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Congratulations on your offers')
    expect(result.text).to include('You have 10 days (until 3 April 2021) to respond. If you do not respond, your offers will automatically be declined.')
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
        decline_by_default_at: status == 'offer' ? 10.days.from_now : nil,
      )
    end

    application_form
  end
end
