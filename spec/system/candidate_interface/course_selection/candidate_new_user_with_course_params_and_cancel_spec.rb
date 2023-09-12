require 'rails_helper'

RSpec.feature 'Candidate tries to sign in after selecting a course in find without an account then says no to selecting the course', continuous_applications: false do
  include SignInHelper

  scenario 'Candidate signs in and receives an email inviting them to sign up and is prompted to select the course' do
    given_i_am_a_candidate_without_an_account
    and_there_is_a_course_with_multiple_sites

    when_i_follow_a_link_from_find
    and_i_confirm_i_am_not_already_signed_up
    and_i_submit_my_email_address
    then_i_receive_an_email_inviting_me_to_sign_up

    when_i_click_on_the_link_in_my_email
    then_i_am_taken_to_the_selected_course_page

    when_i_say_no
    then_i_see_empty_course_review_page
  end

  def given_i_am_a_candidate_without_an_account
    @email = "#{SecureRandom.hex}@example.com"
  end

  def and_there_is_a_course_with_multiple_sites
    @course = create(:course, :open_on_apply, name: 'Potions')
    @course_options = create_list(:course_option, 3, course: @course)
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def and_i_confirm_i_am_not_already_signed_up
    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    click_on t('continue')
  end

  def then_i_receive_an_email_inviting_me_to_sign_up
    open_email(@email)
    expect(current_email.subject).to have_content t('authentication.sign_up.email.subject')
  end

  def when_i_click_on_the_link_in_my_email
    click_magic_link_in_email
    confirm_create_account
  end

  def then_i_am_taken_to_the_selected_course_page
    expect(page).to have_content('You selected a course')
    expect(page).to have_content(@course.provider.name)
    expect(page).to have_content(@course.name_and_code)
  end

  def when_i_say_no
    choose 'No'
    click_on t('continue')
  end

  def then_i_see_empty_course_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
    expect(page).not_to have_content(@course.provider.name)
    expect(page).not_to have_content(@course.name)
  end
end
