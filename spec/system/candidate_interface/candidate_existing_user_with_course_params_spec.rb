require 'rails_helper'

RSpec.describe 'An existing candidate arriving from Find with a course and provider code' do
  include CourseOptionHelpers
  scenario 'retaining their course selection through the sign up process' do
    given_the_pilot_is_open
    and_confirm_course_choice_from_find_is_activated
    and_i_am_an_existing_candidate_on_apply
    and_i_have_less_than_3_application_options
    and_the_course_i_selected_only_has_one_site

    when_i_arrive_at_the_sign_up_page_with_course_params_with_one_site
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_courses_review_page
    and_i_should_see_the_course_name_and_code
    and_i_should_see_the_site
    and_my_course_from_find_id_should_be_set_to_nil

    given_the_course_i_selected_has_multiple_sites
    and_i_am_an_existing_candidate_on_apply
    and_i_have_less_than_3_application_options

    when_i_arrive_at_the_sign_up_page_with_course_params_with_multiple_sites
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_course_choices_site_page
    and_i_see_the_form_to_pick_a_location
    and_my_course_from_find_id_should_be_set_to_nil

    and_the_course_i_selected_only_has_one_site
    and_i_am_an_existing_candidate_on_apply
    and_i_have_3_application_options

    when_i_arrive_at_the_sign_up_page_with_course_params_with_multiple_sites
    and_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_courses_review_page
    and_my_course_from_find_id_should_be_set_to_nil
    and_i_should_be_informed_i_already_have_3_courses
  end

  def and_confirm_course_choice_from_find_is_activated
    FeatureFlag.activate('confirm_course_choice_from_find')
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_course_i_selected_only_has_one_site
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course, vacancy_status: 'B')
  end

  def and_i_am_an_existing_candidate_on_apply
    @email = "#{SecureRandom.hex}@example.com"
    @candidate = create(:candidate, email_address: @email)
  end

  def and_i_have_less_than_3_application_options
    application_choice_for_candidate(candidate: @candidate, application_choice_count: 2)
  end

  def and_i_have_3_application_options
    application_choice_for_candidate(candidate: @candidate, application_choice_count: 3)
  end

  def when_i_arrive_at_the_sign_up_page_with_course_params_with_one_site
    visit candidate_interface_sign_up_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def when_i_arrive_at_the_sign_up_page_with_course_params_with_multiple_sites
    visit candidate_interface_sign_up_path providerCode: @course_with_multiple_sites.provider.code, courseCode: @course_with_multiple_sites.code
  end

  def and_i_submit_my_email_address
    perform_enqueued_jobs do
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

  def and_i_see_the_form_to_pick_a_location
    expect(page).to have_content @site1.name
    expect(page).to have_content @site1.address_line1
    expect(page).to have_content @site1.address_line2
    expect(page).to have_content @site1.address_line3
    expect(page).to have_content @site1.address_line4
    expect(page).to have_content @site1.postcode
    expect(page).to have_content @site2.name
    expect(page).to have_content @site2.address_line1
    expect(page).to have_content @site2.address_line2
    expect(page).to have_content @site2.address_line3
    expect(page).to have_content @site2.address_line4
    expect(page).to have_content @site2.postcode
  end

  def and_my_course_from_find_id_should_be_set_to_nil
    candidate = Candidate.find_by!(email_address: @email)
    expect(candidate.course_from_find_id).to eq(nil)
  end

  def given_the_course_i_selected_has_multiple_sites
    @course_with_multiple_sites = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Herbology')
    @site1 = create(:site, provider: @course_with_multiple_sites.provider)
    @site2 = create(:site, provider: @course_with_multiple_sites.provider)
    create(:course_option, site: @site1, course: @course_with_multiple_sites, vacancy_status: 'B')
    create(:course_option, site: @site2, course: @course_with_multiple_sites, vacancy_status: 'B')
  end

  def then_i_should_see_the_course_choices_site_page
    expect(page).to have_current_path(candidate_interface_course_choices_site_path(@course_with_multiple_sites.provider.code, @course_with_multiple_sites.code))
  end

  def then_i_should_see_the_candidate_interface_application_form
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_should_be_informed_i_already_have_3_courses
    expect(page).to have_content "You cannot have more than 3 course choices. You must delete a choice if you want to apply to #{@course_with_multiple_sites.name_and_code}"
  end

private

  def application_choice_for_candidate(candidate:, application_choice_count:)
    provider = create(:provider)
    application_form = create(:application_form, candidate: candidate)
    application_choice_count.times { course_option_for_provider(provider: provider) }
    provider.courses.each do |course|
      create(:application_choice, application_form: application_form, course_option_id: course.course_options.first.id)
    end
  end
end
