require 'rails_helper'

RSpec.describe 'A new candidate arriving from Find with a course and provider code' do
  include FindAPIHelper

  scenario 'retaining their course selection through the sign up process' do
    given_confirm_course_choice_from_find_is_activated

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_click_apply_on_apply
    then_the_url_should_contain_the_course_code_and_provider_code_param
    and_i_fill_in_the_eligiblity_form_with_yes
    then_the_url_should_contain_the_course_code_and_provider_code_param
  end

  def given_confirm_course_choice_from_find_is_activated
    FeatureFlag.activate('confirm_course_choice_from_find')
  end

  def when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    visit candidate_interface_apply_from_find_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def and_i_click_apply_on_apply
    click_on t('apply_from_find.apply_button')
  end

  def then_the_url_should_contain_the_course_code_and_provider_code_param
    expect(page.current_url).to have_content "providerCode=#{@course.provider.code}"
    expect(page.current_url).to have_content "courseCode=#{@course.code}"
  end

  def and_i_fill_in_the_eligiblity_form_with_yes
    within_fieldset('Are you a citizen of the UK, EU or EEA?') do
      choose 'Yes'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end
end
