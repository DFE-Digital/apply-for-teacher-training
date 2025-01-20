require 'rails_helper'

RSpec.describe 'CandidateInterface ApplicationChoice index' do
  include CandidateHelper

  scenario 'Application rejected with reasons_for_rejection is visible' do
    given_i_am_signed_in_with_one_login
    and_i_have_a_rejected_application

    when_i_visit_my_applications
    and_i_click_to_view_my_application
    then_i_see_my_application_shows_the_application_rejection_reason
    and_i_see_the_rejection_feedback_form
  end

  def and_i_have_a_rejected_application
    @application_choice = create(:application_choice, :reasons_for_rejection, application_form: create(:application_form, candidate: @current_candidate))
  end

  def then_i_see_my_application_shows_the_application_rejection_reason
    expect(page.text).to include('Something you did',
                                 'Didn’t reply to our interview offer.',
                                 'Didn’t attend interview.',
                                 'Persistent scratching',
                                 'Not scratch so much',
                                 'Quality of application',
                                 'Personal statement',
                                 'Use a spellchecker',
                                 'Subject knowledge',
                                 "Claiming to be the 'world's leading expert' seemed a bit strong",
                                 'Lights on but nobody home',
                                 'Study harder',
                                 'Qualifications',
                                 'No English GCSE grade 4 (C) or above, or valid equivalent.',
                                 'All the other stuff',
                                 'Performance at interview',
                                 'Be fully dressed',
                                 'Honesty and professionalism',
                                 'Fake news',
                                 'Clearly not a popular student',
                                 'Safeguarding issues',
                                 'We need to run further checks')
  end

  def and_i_see_the_rejection_feedback_form
    expect(page.text).to include('Is this feedback helpful?',
                                 'Yes',
                                 'No')
  end
end
