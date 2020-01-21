require 'rails_helper'

RSpec.describe 'A new candidate arriving from Find with a course and provider code' do
  include FindAPIHelper
  include ActiveJob::TestHelper

  scenario 'retaining their course selection through the sign up process' do
    given_the_pilot_is_open
    given_confirm_course_choice_from_find_is_activated
    given_the_course_i_selected_only_has_one_site

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_click_apply_on_apply
    then_the_url_should_contain_the_course_code_and_provider_code_param
    and_i_fill_in_the_eligiblity_form_with_yes
    then_the_url_should_contain_the_course_code_and_provider_code_param

    when_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_courses_review_page
    and_i_should_see_the_course_name_and_code
    and_i_should_see_the_site
    and_my_find_from_id_course_should_be_set_to_nil

    # given_the_course_i_selected_has_multiple_sites
    #
    # and_i_login_via_the_magic_link
    # then_i_should_see_the_course_choices_site_page
    # and_i_should_see_the_course_name
    # and_i_should_see_the_course_code
    # and_i_should_see_the_first_site
    # and_i_should_see_the_second_site
  end

  def given_confirm_course_choice_from_find_is_activated
    FeatureFlag.activate('confirm_course_choice_from_find')
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_the_course_i_selected_only_has_one_site
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course, vacancy_status: 'B')
  end

  def when_i_arrive_from_find_to_a_course_that_is_open_on_apply
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

  def when_i_submit_my_email_address
    perform_enqueued_jobs do
      @email = "#{SecureRandom.hex}@example.com"
      fill_in t('authentication.sign_up.email_address.label'), with: @email
      check t('authentication.sign_up.accept_terms_checkbox')
      click_on t('authentication.sign_up.button_continue')
    end
  end

  def and_click_on_the_magic_link
    open_email(@email)
    current_email.find_css('a').first.click
  end

  def then_i_should_see_the_courses_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_see_the_course_name_and_code
    expect(page).to have_content "#{@course.name} (#{@course.code})"
  end

  def and_i_should_see_the_site
    expect(page).to have_content @site.name
    expect(page).to have_content @site.address_line1
    expect(page).to have_content @site.address_line2
    expect(page).to have_content @site.address_line3
    expect(page).to have_content @site.address_line4
    expect(page).to have_content @site.postcode
  end

  def and_my_find_from_id_course_should_be_set_to_nil
    candidate = Candidate.find_by!(email_address: @email)
    expect(candidate.course_from_find_id).to eq(nil)
  end
end
