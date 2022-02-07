require 'rails_helper'

RSpec.feature 'An existing candidate arriving from Find with a course and provider code' do
  include CourseOptionHelpers
  scenario 'candidate is signed in' do
    given_the_pilot_is_open
    and_apply_again_with_three_choices_are_inactive
    and_i_am_an_existing_candidate_on_apply
    and_i_have_less_than_3_application_options
    and_the_course_i_selected_only_has_one_site
    and_i_am_signed_in

    when_i_arrive_at_the_apply_from_find_page_with_course_params_with_one_site
    then_i_should_see_the_course_selection_page

    when_i_say_yes
    then_i_should_see_the_courses_review_page
    and_i_should_see_the_course_name_and_code

    when_i_arrive_at_the_apply_from_find_page_with_the_same_course_params
    then_i_should_see_the_courses_review_page
    and_i_should_be_informed_i_have_already_selected_that_course

    given_the_course_i_selected_has_multiple_sites
    and_i_am_an_existing_candidate_on_apply
    and_i_am_signed_in
    and_i_have_less_than_3_application_options

    when_i_arrive_at_the_apply_from_find_page_with_course_params_with_multiple_sites
    then_i_should_see_the_multi_site_course_selection_page

    when_i_say_yes
    then_i_should_see_the_course_choices_site_page
    and_i_see_the_form_to_pick_a_location

    given_the_course_i_selected_has_multiple_sites
    and_i_am_an_existing_candidate_on_apply
    and_i_am_signed_in
    and_i_have_3_application_options

    when_i_arrive_at_the_apply_from_find_page_with_course_params_with_one_site
    then_i_should_see_the_courses_review_page
    and_i_should_be_informed_i_already_have_3_courses

    given_the_course_i_selected_has_multiple_sites
    and_i_am_an_existing_candidate_on_apply
    and_i_am_signed_in
    and_i_am_applying_again
    and_i_have_1_application_choice

    when_i_arrive_at_the_apply_from_find_page_with_course_params_with_one_site
    then_i_should_see_the_courses_review_page
    and_i_should_be_informed_i_can_only_have_1_course_choice
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_course_i_selected_only_has_one_site
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course)
  end

  def and_i_am_an_existing_candidate_on_apply
    @email = "#{SecureRandom.hex}@example.com"
    @candidate = create(:candidate, email_address: @email)
  end

  def and_i_have_less_than_3_application_options
    application_form = create(:application_form, candidate: @candidate)
    create(:application_choice, application_form: application_form)
  end

  def and_i_have_3_application_options
    application_choice_for_candidate(candidate: @candidate, application_choice_count: 3)
  end

  def and_i_am_signed_in
    login_as(@candidate)
  end

  def when_i_arrive_at_the_apply_from_find_page_with_course_params_with_one_site
    visit candidate_interface_apply_from_find_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def when_i_arrive_at_the_apply_from_find_page_with_course_params_with_multiple_sites
    visit candidate_interface_apply_from_find_path providerCode: @course_with_multiple_sites.provider.code, courseCode: @course_with_multiple_sites.code
  end

  def when_i_arrive_at_the_apply_from_find_page_with_the_same_course_params
    visit candidate_interface_apply_from_find_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def then_i_should_see_the_course_selection_page
    expect(page).to have_content('You selected a course')
    expect(page).to have_content(@course.provider.name)
    expect(page).to have_content(@course.name_and_code)
  end

  def then_i_should_see_the_multi_site_course_selection_page
    expect(page).to have_content('You selected a course')
    expect(page).to have_content(@course_with_multiple_sites.provider.name)
    expect(page).to have_content(@course_with_multiple_sites.name_and_code)
  end

  def when_i_say_yes
    choose 'Yes'
    click_on t('continue')
  end

  def and_i_submit_my_email_address
    fill_in t('authentication.sign_up.email_address.label'), with: @email
    check t('authentication.sign_up.accept_terms_checkbox')
    click_on t('continue')
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

  def given_the_course_i_selected_has_multiple_sites
    @course_with_multiple_sites = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Herbology')
    @site1 = create(:site, provider: @course_with_multiple_sites.provider)
    @site2 = create(:site, provider: @course_with_multiple_sites.provider)
    create(:course_option, site: @site1, course: @course_with_multiple_sites)
    create(:course_option, site: @site2, course: @course_with_multiple_sites)
  end

  def then_i_should_see_the_course_choices_site_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_site_path(
        @course_with_multiple_sites.provider.id,
        @course_with_multiple_sites.id,
        :full_time,
      ),
    )
  end

  def then_i_should_see_the_candidate_interface_application_form
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_should_be_informed_i_already_have_3_courses
    expect(page).to have_content I18n.t('errors.messages.too_many_course_choices', course_name_and_code: @course.name_and_code)
  end

  def when_i_sign_out
    click_link 'Sign out'
  end

  def and_i_arrive_at_the_apply_from_find_page_with_the_same_course_params
    visit candidate_interface_sign_up_path providerCode: @course.provider.code, courseCode: @course.code
  end

  def and_i_should_be_informed_i_have_already_selected_that_course
    expect(page).to have_content "You have already selected #{@course.name_and_code}."
  end

  def and_i_am_applying_again
    @candidate.current_application.apply_2!
  end

  def and_i_have_1_application_choice
    create(:application_choice, application_form: @candidate.current_application)
  end

  def and_i_should_be_informed_i_can_only_have_1_course_choice
    expect(page).to have_content t('errors.messages.apply_again_course_already_chosen', course_name_and_code: @course.name_and_code)
  end

  def and_apply_again_with_three_choices_are_inactive
    FeatureFlag.deactivate(:apply_again_with_three_choices)
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
