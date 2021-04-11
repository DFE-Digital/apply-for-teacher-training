require 'rails_helper'

RSpec.describe 'An existing candidate arriving from Find with a course and provider code (with course selection page)' do
  include CourseOptionHelpers
  include SignInHelper

  scenario 'candidate is not signed in and retains their course selection through the sign in process' do
    given_the_pilot_is_open

    # Single site course
    and_i_am_an_existing_candidate_on_apply
    and_i_have_less_than_3_application_options
    and_the_course_i_selected_only_has_one_site
    when_i_arrive_at_the_apply_from_find_page_with_the_single_site_course_params
    and_i_go_to_sign_in
    then_i_should_see_the_course_selection_page
    and_i_should_see_a_link_to_the_course_on_find

    when_i_say_yes
    then_i_should_see_the_courses_review_page
    and_i_should_see_the_course_name_and_code
    and_my_course_from_find_id_should_be_set_to_nil
    when_i_sign_out
    when_i_arrive_at_the_apply_from_find_page_with_the_single_site_course_params
    and_i_go_to_sign_in
    then_i_should_see_the_courses_review_page
    and_i_should_be_informed_i_have_already_selected_that_course

    # Multi-site course
    given_i_am_signed_out
    given_the_course_i_selected_has_multiple_sites
    and_i_am_an_existing_candidate_on_apply
    and_i_have_less_than_3_application_options
    when_i_arrive_at_the_apply_from_find_page_with_the_multi_site_course_params
    and_i_go_to_sign_in
    then_i_should_see_the_multi_site_course_selection_page
    when_i_say_yes
    and_i_select_the_part_time_study_mode
    then_i_should_see_the_course_choices_site_page
    and_i_see_the_form_to_pick_a_location
    and_my_course_from_find_id_should_be_set_to_nil

    given_i_am_signed_out
    and_the_course_i_selected_only_has_one_site
    and_i_am_an_existing_candidate_on_apply
    and_i_have_3_application_options
    when_i_arrive_at_the_apply_from_find_page_with_the_multi_site_course_params
    and_i_go_to_sign_in
    then_i_should_see_the_courses_review_page
    and_my_course_from_find_id_should_be_set_to_nil
    and_i_should_be_informed_i_already_have_3_courses
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def given_i_am_signed_out
    when_i_sign_out
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

  def when_i_arrive_at_the_apply_from_find_page_with_the_single_site_course_params
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def when_i_arrive_at_the_apply_from_find_page_with_the_multi_site_course_params
    visit candidate_interface_apply_from_find_path(
      providerCode: @course_with_multiple_sites.provider.code,
      courseCode: @course_with_multiple_sites.code,
    )
  end

  def and_i_go_to_sign_in
    choose 'Yes, I want to apply using the new service'
    click_button t('continue')

    choose 'Yes, sign in'
    fill_in 'Email', with: @email
    click_button t('continue')

    open_email(@email)
    click_magic_link_in_email
    confirm_sign_in
  end

  def and_i_have_less_than_3_application_options
    application_form = create(:application_form, candidate: @candidate)
    create(:application_choice, application_form: application_form)
  end

  def and_i_have_3_application_options
    application_choice_for_candidate(candidate: @candidate, application_choice_count: 3)
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

  def then_i_should_see_the_courses_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_see_the_course_name_and_code
    expect(page).to have_content "#{@course.name} (#{@course.code})"
  end

  def and_i_see_the_form_to_pick_a_location
    expect(page).to have_content @site2.name
    expect(page).to have_content @site2.address_line1
    expect(page).to have_content @site2.address_line2
    expect(page).to have_content @site2.address_line3
    expect(page).to have_content @site2.address_line4
    expect(page).to have_content @site2.postcode
    expect(page).to have_content @site3.name
    expect(page).to have_content @site3.address_line1
    expect(page).to have_content @site3.address_line2
    expect(page).to have_content @site3.address_line3
    expect(page).to have_content @site3.address_line4
    expect(page).to have_content @site3.postcode
  end

  def and_my_course_from_find_id_should_be_set_to_nil
    candidate = Candidate.find_by!(email_address: @email)
    expect(candidate.course_from_find_id).to eq(nil)
  end

  def given_the_course_i_selected_has_multiple_sites
    @course_with_multiple_sites = create(
      :course,
      :with_both_study_modes,
      exposed_in_find: true,
      open_on_apply: true,
      name: 'Herbology',
    )
    @site1 = create(:site, provider: @course_with_multiple_sites.provider)
    @site2 = create(:site, provider: @course_with_multiple_sites.provider)
    @site3 = create(:site, provider: @course_with_multiple_sites.provider)
    create(:course_option, :full_time, site: @site1, course: @course_with_multiple_sites)
    create(:course_option, :part_time, site: @site2, course: @course_with_multiple_sites)
    create(:course_option, :part_time, site: @site3, course: @course_with_multiple_sites)
  end

  def and_i_select_the_part_time_study_mode
    choose 'Part time'
    click_button t('continue')
  end

  def then_i_should_see_the_course_choices_site_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_site_path(
        @course_with_multiple_sites.provider.id,
        @course_with_multiple_sites.id,
        :part_time,
      ),
    )
  end

  def and_i_should_be_informed_i_already_have_3_courses
    expect(page).to have_content I18n.t('errors.messages.too_many_course_choices', course_name_and_code: @course_with_multiple_sites.name_and_code)
  end

  def when_i_sign_out
    click_link 'Sign out'
  end

  def and_i_should_be_informed_i_have_already_selected_that_course
    expect(page).to have_content "You have already selected #{@course.name_and_code}."
  end

  def and_i_should_see_a_link_to_the_course_on_find
    expect(page).to have_link(
      "#{@course.provider.name} #{@course.name_and_code}",
      href: "https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{@course.provider.code}/#{@course.code}",
    )
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
