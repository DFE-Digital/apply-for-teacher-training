require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionSearchResultsComponent do
  def render_result(
    application_choices,
    search_attribute = :quality_of_application_y_n,
    search_value = 'Yes'
  )
    @rendered_result ||= render_inline(
      described_class.new(
        search_attribute: search_attribute,
        search_value: search_value,
        application_choices: application_choices,
      ),
    )
  end

  context 'for a top-level reason' do
    before do
      @application_choice = build(
        :application_choice,
        structured_rejection_reasons: {
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'Avoid humming',
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_maths_gcse no_degree],
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[other],
          quality_of_application_other_details: 'Too many emojis',
          interested_in_future_applications_y_n: 'Yes',
          other_advice_or_feedback_y_n: 'Yes',
          other_advice_or_feedback_details: 'You need a haircut',
          why_are_you_rejecting_this_application: ''

        },
        application_form_id: 123,
      )
      render_result([@application_choice])
    end

    it 'renders a link to the application form' do
      expect(@rendered_result.css("a[href='/support/applications/123']")).to be_present
    end

    it 'renders top-level reasons' do
      expect(@rendered_result.text).to include('Qualifications')
      expect(@rendered_result.text).to include('Quality of application')
      expect(@rendered_result.text).to include('Performance at interview')
      expect(@rendered_result.text).to include('Avoid humming')
      expect(@rendered_result.text).to include('Future applications')
      expect(@rendered_result.text).not_to include('Something you did')
    end

    it 'renders sub-reasons' do
      expect(@rendered_result.text).to include('No Maths GCSE')
      expect(@rendered_result.text).to include('No degree')
      expect(@rendered_result.text).to include('Other - Too many emojis')
      expect(@rendered_result.text).to include('Yes')
      expect(@rendered_result.text).to include('You need a haircut')
      expect(@rendered_result.text).not_to include('No Science GCSE')
      expect(@rendered_result.text).not_to include('No English GCSE')
    end

    it 'highlights the search term' do
      expect(@rendered_result.css('mark').text).to eq 'Quality of application'
    end

    it 'hides empty rejection reasons' do
      expect(@rendered_result.text).not_to include 'Reasons why your application was unsuccessful'
    end
  end

  context 'for a sub-reason' do
    before do
      @application_choice = build(
        :application_choice,
        structured_rejection_reasons: {
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_maths_gcse no_degree],
          quality_of_application_y_n: 'Yes',
        },
        application_form_id: 123,
      )
      render_result([@application_choice], :qualifications_which_qualifications, :no_degree)
    end

    it 'highlights the search term' do
      expect(@rendered_result.css('mark').text).to eq 'No degree'
    end
  end

  context 'error handling' do
    it 'handles an invalid top-level attribute param' do
      expect { render_result([], :velocity_of_application_y_n, 'Yes') }.not_to raise_error
    end

    it 'handles an invalid sub-reason value param' do
      expect { render_result([], :qualifications_which_qualifications, 'no_pilots_licence') }.not_to raise_error
    end

    it 'handles an invalid reason and sub-reason' do
      @application_choice = build(
        :application_choice,
        structured_rejection_reasons: {
          performance_at_singing_y_n: 'Yes',
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_cycling_proficiency],
        },
        application_form_id: 123,
      )
      expect { render_result([@application_choice], :qualifications_which_qualifications, 'no_degree') }.not_to raise_error
    end
  end
end
