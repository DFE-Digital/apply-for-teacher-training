require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::MidCycleUnsuccessfulContentComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:application_form) { build_stubbed(:application_form) }
  let(:component) { described_class.new(application_form: application_form) }

  it 'states You cannot submit any more applications this year' do
    apply_reopens_date = application_form.recruitment_cycle_timetable.apply_reopens_at.to_fs(:month_and_year)

    render_inline(component)

    expect(rendered_content).to include('You cannot submit any more applications this year')
    expect(rendered_content).to include('This is because you have reached the limit of 15 applications in this recruitment cycle.')
    expect(rendered_content).to include('All of your applications have since:')
    expect(rendered_content).to include(
      'been rejected by the provider',
      'been withdrawn (by you or the training provider)',
      'been waiting for a response for more than 30 working days',
      'received an offer you declined',
      'received an offer where you did not meet the conditions',
    )
    expect(rendered_content).to include(
      "You will be able to submit more applications in the next recruitment cycle starting #{apply_reopens_date}.",
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

    it 'does not have the unsuccessful applications message' do
      apply_reopens_date = application_form.recruitment_cycle_timetable.apply_reopens_at.to_fs(:month_and_year)

      render_inline(component)

      expect(rendered_content).to include('You cannot submit any more applications this year')
      expect(rendered_content).to include('This is because you’ve submitted all 4 of your applications in this recruitment cycle.')
      expect(rendered_content).not_to include('All of your applications have since:')
      expect(rendered_content).not_to include(
        'been rejected by the provider',
        'been withdrawn (by you or the training provider)',
        'been waiting for a response for more than 30 working days',
        'received an offer you declined',
        'received an offer where you did not meet the conditions',
      )
      expect(rendered_content).to include(
        "You will be able to submit more applications in the next recruitment cycle starting #{apply_reopens_date}.",
      )
      expect(rendered_content).to have_no_link(
        'Add application',
        href: candidate_interface_course_choices_do_you_know_the_course_path,
      )
    end
  end
end
