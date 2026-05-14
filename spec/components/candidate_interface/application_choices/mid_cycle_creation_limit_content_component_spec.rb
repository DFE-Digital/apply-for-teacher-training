require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::MidCycleCreationLimitContentComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:application_form) { build_stubbed(:application_form) }
  let(:component) { described_class.new(application_form: application_form) }

  before do
    allow(application_form).to receive_messages(
      number_of_in_progress_applications_left: 3,
    )
  end

  it 'states You have 4 applications in progress. This is the maximum allowed.' do
    apply_reopens_at_string = application_form.apply_reopens_at.to_fs(:month_and_year)

    render_inline(component)

    expect(rendered_content).to include('You can submit 3 applications.')
    expect(rendered_content).to include('You currently have 4 active applications, so you cannot start a new one right now.')
    expect(rendered_content).to include('You can add another application if one of your current applications:')
    expect(rendered_content).to include(
      'is rejected by the provider',
      'is withdrawn (by you or the provider)',
      'has been waiting for a response from a provider for more than 30 working days',
      'has an offer that you declined',
      'has an offer where you did not meet the conditions',
    )
    expect(rendered_content).to include('If you have a draft application, you’ll need to delete it before you can start a new application.')
    expect(rendered_content).to include("Once you’ve submitted 15 applications, you will not be able to submit any more until the next recruitment cycle starting #{apply_reopens_at_string}.")
    expect(rendered_content).to have_link(
      'Find out how the application process works',
      href: candidate_interface_guidance_path,
    )
    expect(rendered_content).to have_no_link(
      'Add application',
      href: candidate_interface_course_choices_do_you_know_the_course_path,
    )
  end

  context 'when the total_application limit is the same as the in_progress limit' do
    before do
      allow(application_form).to receive(:limits).and_return(ChoiceLimitsCalculator::Limits.new(in_progress_limit: 4, unsuccessful_retry_limit: 0))
    end

    it 'does not have the how to add more applications message' do
      apply_reopens_at_string = application_form.apply_reopens_at.to_fs(:month_and_year)

      render_inline(component)

      expect(rendered_content).to include('You can submit 3 applications.')
      expect(rendered_content).to include('You currently have 4 active applications, so you cannot start a new one right now.')
      expect(rendered_content).not_to include('You can add another application if one of your current applications:')
      expect(rendered_content).not_to include(
        'is rejected by the provider',
        'is withdrawn (by you or the provider)',
        'has been waiting for a response from a provider for more than 30 working days',
        'has an offer that you declined',
        'has an offer where you did not meet the conditions',
      )
      expect(rendered_content).to include('If you have a draft application, you’ll need to delete it before you can start a new application.')
      expect(rendered_content).to include("Once you’ve submitted 4 applications, you will not be able to submit any more until the next recruitment cycle starting #{apply_reopens_at_string}.")
      expect(rendered_content).to have_link(
        'Find out how the application process works',
        href: candidate_interface_guidance_path,
      )
      expect(rendered_content).to have_no_link(
        'Add application',
        href: candidate_interface_course_choices_do_you_know_the_course_path,
      )
    end
  end
end
