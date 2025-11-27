require 'rails_helper'

RSpec.describe 'Candidate reviews their application' do
  include CandidateHelper

  context 'when the candidate is a domestic candidate' do
    scenario 'Candidate reviews their application' do
      given_i_am_a_candidate_with_a_complete_an_application
      and_i_have_an_unsubmitted_application_choice
      when_i_review_my_application_choice
      then_i_see_the_application_review_page
      and_i_do_not_see_the_funding_advise
    end
  end

  context 'when the candidate is an international candidate' do
    scenario 'Candidate reviews their application' do
      given_i_am_a_candidate_with_a_complete_an_application_with_skilled_worker_visa
      and_i_have_an_unsubmitted_application_choice
      when_i_review_my_application_choice
      then_i_see_the_application_review_page
      and_i_see_the_funding_advise
    end

    scenario 'Candidate reviews their application for physics' do
      given_i_am_a_candidate_with_a_complete_an_application_with_skilled_worker_visa
      and_i_have_an_unsubmitted_application_choice_for_physics
      when_i_review_my_application_choice
      then_i_see_the_application_review_page
      and_i_do_not_see_the_funding_advise
    end

    scenario 'Candidate reviews their application for a language' do
      given_i_am_a_candidate_with_a_complete_an_application_with_skilled_worker_visa
      and_i_have_an_unsubmitted_application_choice_for_french
      when_i_review_my_application_choice
      then_i_see_the_application_review_page
      and_i_do_not_see_the_funding_advise
    end
  end

  private

  def given_i_am_a_candidate_with_a_complete_an_application
    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
    )
  end

  def given_i_am_a_candidate_with_a_complete_an_application_with_skilled_worker_visa
    @application_form = create(
      :application_form,
      :completed,
      :with_degree,
      candidate: current_candidate,
      first_nationality: 'Indian',
      second_nationality: nil,
      right_to_work_or_study: 'yes',
      immigration_status: 'skilled_worker_visa',
      efl_completed: true,
    )
  end

  def and_i_have_an_unsubmitted_application_choice
    @application_choice = create(:application_choice, status: 'unsubmitted', application_form: @application_form)
    @course = @application_choice.course
    @course.update!(can_sponsor_student_visa: true, funding_type: 'fee', fee_domestic: 9000, fee_international: 16000)
    @provider = @application_choice.provider
  end

  def and_i_have_an_unsubmitted_application_choice_for_physics
    @physics_subject = create(:subject, name: 'Physics', code: 'F3')
    @application_choice = create(:application_choice, status: 'unsubmitted', application_form: @application_form)
    @course = @application_choice.course
    @course.subjects << @physics_subject
    @course.update!(can_sponsor_student_visa: true, funding_type: 'fee', fee_domestic: 9000, fee_international: 16000)
    @provider = @application_choice.provider
  end

  def and_i_have_an_unsubmitted_application_choice_for_french
    @french_subject = create(:subject, name: 'French', code: '15')
    @application_choice = create(:application_choice, status: 'unsubmitted', application_form: @application_form)
    @course = @application_choice.course
    @course.subjects << @french_subject
    @course.update!(can_sponsor_student_visa: true, funding_type: 'fee', fee_domestic: 9000, fee_international: 16000)
    @provider = @application_choice.provider
  end

  def when_i_review_my_application_choice
    login_as(current_candidate)
    visit root_path
    click_on 'Your applications'
    click_on @provider.name
    click_on 'Review application'
  end

  def then_i_see_the_application_review_page
    expect(page).to have_title(
      "Review your application to #{@provider.name}",
    )
    expect(page).to have_link("#{@course.name} (#{@course.code}) (opens in new tab)")
    expect(page).to have_element(:p, text: '£9,000')
    expect(page).to have_element(:p, text: '£16,000')

    expect(page).to have_element(:h2, text: 'Qualifications')
    expect(page).to have_element(
      :div,
      text: 'You will need to show original copies of your qualifications. You may need to have them translated if they are not in English.',
      class: 'govuk-warning-text',
    )
  end

  def and_i_see_the_funding_advise
    expect(page).to have_element(
      :p,
      text: 'Non-UK citizens are unlikely to get help funding your training unless you have permission to live permanently in the UK. Find out about funding for non-UK citizens (opens in new tab)',
    )
  end

  def and_i_do_not_see_the_funding_advise
    expect(page).not_to have_element(
      :p,
      text: 'Non-UK citizens are unlikely to get help funding your training unless you have permission to live permanently in the UK. Find out about funding for non-UK citizens (opens in new tab)',
    )
  end
end
