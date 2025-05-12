require 'rails_helper'

RSpec.describe 'CandidateInterface ApplicationChoice index' do
  include CandidateHelper

  scenario 'Application rejected with rejection_reasons is visible' do
    given_i_am_signed_in_with_one_login
    and_i_have_a_rejected_application
    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_my_application_shows_the_application_rejection_reason
    and_i_see_the_rejection_feedback_form
  end

  def and_i_have_a_rejected_application
    @application_choice = create(:application_choice, :rejected_reasons, application_form: create(:application_form, candidate: @current_candidate))
  end

  def then_i_see_my_application_shows_the_application_rejection_reason
    expect(page.text).to include('Qualifications',
                                 'We could find no record of your GCSEs.',
                                 'Personal statement',
                                 'We do not accept applications written in Old Norse.',
                                 'References',
                                 'We do not accept references from close family members, such as your mum.')
  end

  def and_i_see_the_rejection_feedback_form
    expect(page.text).to include('Is this feedback helpful?',
                                 'Yes',
                                 'No')
  end
end
