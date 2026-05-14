require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationChoices::MidCycleAddMoreContentComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:application_form) { build_stubbed(:application_form) }
  let(:component) { described_class.new(application_form: application_form) }

  context 'when the candidate has not submitted' do
    before do
      allow(application_form).to receive_messages(
        unsuccessful_limit_reached?: false,
        can_add_more_choices?: true,
        submitted?: false,
      )
    end

    it 'states You can submit up to 4 applications at a time.' do
      render_inline(component)

      expect(rendered_content).to include('You can submit up to 4 applications at a time.')
      expect(rendered_content).to include('If a submitted application becomes inactive, is withdrawn or rejected you can add another, up to a maximum of 15 applications in a single recruitment cycle.')
      expect(rendered_content).to have_link(
        'Find out how the application process works',
        href: candidate_interface_guidance_path,
      )
      expect(rendered_content).to include('Training providers offer places on courses throughout the year. Courses can fill up quickly, so you should apply as soon as you are ready.')
      expect(rendered_content).to include('Once a course is full, it will close. You will not be able to apply for that course with that training provider until next year.')
      expect(rendered_content).to have_link(
        'Add application',
        href: candidate_interface_course_choices_do_you_know_the_course_path,
      )
    end

    context 'when there are no unsuccessful_retries allowed' do
      before do
        allow(application_form).to receive(:limits).and_return(ChoiceLimitsCalculator::Limits.new(in_progress_limit: 4, unsuccessful_retry_limit: 0))
      end

      it 'states You can submit up to 4 applications in the cycle' do
        render_inline(component)

        expect(rendered_content).to include('You can submit up to 4 applications in this recruitment cycle.')
        expect(rendered_content).not_to include('If a submitted application becomes inactive, is withdrawn or rejected you can add another, up to a maximum of 15 applications in a single recruitment cycle.')
        expect(rendered_content).to have_link(
          'Find out how the application process works',
          href: candidate_interface_guidance_path,
        )
        expect(rendered_content).to include('Training providers offer places on courses throughout the year. Courses can fill up quickly, so you should apply as soon as you are ready.')
        expect(rendered_content).to include('Once a course is full, it will close. You will not be able to apply for that course with that training provider until next year.')
        expect(rendered_content).to have_link(
          'Add application',
          href: candidate_interface_course_choices_do_you_know_the_course_path,
        )
      end
    end
  end

  context 'when the candidate has submitted' do
    before do
      allow(application_form).to receive_messages(
        unsuccessful_limit_reached?: false,
        can_add_more_choices?: true,
        submitted?: true,
        number_of_slots_left: 3,
      )
    end

    it 'states You can submit more applications.' do
      render_inline(component)

      expect(rendered_content).not_to include('You can have up to 4 applications in progress at any time.')
      expect(rendered_content).to include('You can submit 3 more applications.')
      expect(rendered_content).to include('If a submitted application becomes inactive, is withdrawn or rejected you can add another, up to a maximum of 15 applications in a single recruitment cycle.')
      expect(rendered_content).to have_link(
        'Find out how the application process works',
        href: candidate_interface_guidance_path,
      )
      expect(rendered_content).to include('Training providers offer places on courses throughout the year. Courses can fill up quickly, so you should apply as soon as you are ready.')
      expect(rendered_content).to include('Once a course is full, it will close. You will not be able to apply for that course with that training provider until next year.')
      expect(rendered_content).to have_link(
        'Add application',
        href: candidate_interface_course_choices_do_you_know_the_course_path,
      )
    end

    context 'when the total_application limit is the same as the in_progress limit' do
      before do
        allow(application_form).to receive(:limits).and_return(ChoiceLimitsCalculator::Limits.new(in_progress_limit: 4, unsuccessful_retry_limit: 0))
      end

      it 'does not have the inactive message' do
        render_inline(component)

        expect(rendered_content).not_to include('You can have up to 4 applications in progress at any time.')
        expect(rendered_content).to include('You can submit 3 more applications.')
        expect(rendered_content).not_to include('If a submitted application becomes inactive, is withdrawn or rejected you can add another, up to a maximum of 15 applications in a single recruitment cycle.')
        expect(rendered_content).to have_link(
          'Find out how the application process works',
          href: candidate_interface_guidance_path,
        )
        expect(rendered_content).to include('Training providers offer places on courses throughout the year. Courses can fill up quickly, so you should apply as soon as you are ready.')
        expect(rendered_content).to include('Once a course is full, it will close. You will not be able to apply for that course with that training provider until next year.')
        expect(rendered_content).to have_link(
          'Add application',
          href: candidate_interface_course_choices_do_you_know_the_course_path,
        )
      end
    end
  end
end
