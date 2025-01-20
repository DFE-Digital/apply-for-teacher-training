require 'rails_helper'

RSpec.describe 'Candidate arrives from Find with provider and course params' do
  include CandidateHelper

  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_signed_in_with_one_login

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_course_confirm_selection_page

    when_i_dont_answer
    then_i_see_an_error_message

    when_i_say_no
    then_i_am_redirected_to_your_applications_tab
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5', name: 'Snape University')
    @course = create(:course, :open, name: 'Potions', provider: @provider)
    create(:course_option, course: @course)
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def then_i_am_redirected_to_the_create_account_or_sign_in_path
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(
      providerCode: @provider.code,
      courseCode: @course.code,
    )
  end

  def then_i_am_redirected_to_the_course_confirm_selection_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_confirm_selection_path(@course.id),
    )
  end

  def when_i_dont_answer
    click_link_or_button 'Continue'
  end

  def then_i_see_an_error_message
    expect(page).to have_content(
      I18n.t('activemodel.errors.models.find_course_selection.attributes.confirm.blank'),
    )
  end

  def when_i_say_no
    choose 'No'
    click_link_or_button 'Continue'
  end

  def then_i_am_redirected_to_your_applications_tab
    expect(page).to have_current_path(
      candidate_interface_application_choices_path,
    )
  end
end
