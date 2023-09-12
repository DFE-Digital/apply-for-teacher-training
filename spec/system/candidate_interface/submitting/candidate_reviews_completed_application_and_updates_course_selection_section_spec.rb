require 'rails_helper'

RSpec.feature 'Candidate is redirected correctly' do
  include CandidateHelper
  include CourseOptionHelpers

  it 'Candidate reviews completed application and updates course selection section', continuous_applications: false do
    given_i_am_signed_in
    and_two_courses_are_available
    when_i_add_a_course_choice
    and_i_review_my_application
    then_i_should_see_my_course_choice

    # course_choice
    when_i_click_change_course_choice
    then_i_should_see_the_edit_select_course_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_click_change_the_course_choice_again
    and_i_choose_a_course
    and_i_click_back
    and_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_course_to_a_course_with_two_available_study_modes
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_course_choice

    # study_mode
    when_i_click_change_study_mode
    then_i_should_see_the_edit_study_mode_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_click_change_study_mode_again
    and_i_choose_part_time_study_mode
    and_i_click_back
    and_i_click_back
    and_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_study_mode_and_site
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_study_mode_and_site

    # site
    when_i_click_change_site
    then_i_should_see_the_edit_site_form

    when_i_click_back
    then_i_should_be_redirected_to_the_application_review_page

    when_i_update_the_site
    then_i_should_be_redirected_to_the_application_review_page
    and_i_should_see_the_updated_course_site
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_two_courses_are_available
    @provider = create(:provider)
    site1 = create(:site, provider: @provider)
    site2 = create(:site, provider: @provider)

    create(:course, :open_on_apply, name: 'English', provider: @provider, study_mode: :full_time)
    course_option_for_provider(provider: @provider, course: @provider.courses.first, site: site1)
    course_option_for_provider(provider: @provider, course: @provider.courses.first, site: site2)

    create(:course, :open_on_apply, name: 'Primary', provider: @provider, study_mode: :full_time)
    course_option_for_provider(provider: @provider, course: @provider.courses.second, site: site1)
    course_option_for_provider(provider: @provider, course: @provider.courses.second, site: site2)

    create(:course, :open_on_apply, :with_both_study_modes, name: 'Maths', provider: @provider)
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site: site1, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site: site2, study_mode: 'full_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site: site1, study_mode: 'part_time')
    course_option_for_provider(provider: @provider, course: @provider.courses.third, site: site2, study_mode: 'part_time')
  end

  def when_i_add_a_course_choice
    visit candidate_interface_application_form_path
    click_link 'Choose your courses'
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select @provider.name_and_code
    click_button t('continue')
    choose @provider.courses.first.name_and_code
    click_button t('continue')
    choose @provider.courses.second.course_options.first.site.name
    click_button t('continue')
  end

  def when_i_click_on_check_your_answers
    click_link 'Check and submit your application'
  end

  def and_i_review_my_application
    visit candidate_interface_application_form_path
    when_i_click_on_check_your_answers
  end

  def then_i_should_see_my_course_choice
    expect(page).to have_content @provider.courses.first.name.to_s
  end

  def when_i_click_change_course_choice
    within('[data-qa="course-choice"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_the_course_choice_again
    when_i_click_change_course_choice
  end

  def when_i_click_change_study_mode
    within('[data-qa="course-choice-study-mode"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_study_mode_again
    when_i_click_change_study_mode
  end

  def when_i_click_change_site
    within('[data-qa="course-choice-location"]') do
      click_link 'Change'
    end
  end

  def when_i_click_change_site_again
    when_i_click_change_site
  end

  def then_i_should_see_the_edit_select_course_form
    expect(page).to have_current_path(
      candidate_interface_edit_course_choices_course_path(
        @provider.id,
        course_choice_id: current_candidate.application_choices.first.id,
        'return-to' => 'application-review',
      ),
    )
  end

  def then_i_should_see_the_edit_study_mode_form
    expect(page).to have_current_path(
      candidate_interface_edit_course_choices_study_mode_path(
        @provider.id,
        @provider.courses.third.id,
        course_choice_id: current_candidate.application_choices.first.id,
        'return-to' => 'application-review',
      ),
    )
  end

  def then_i_should_see_the_edit_site_form
    expect(page).to have_current_path(
      candidate_interface_edit_course_choices_site_path(
        @provider.id,
        @provider.courses.third.id,
        @provider.courses.third.course_options.third.study_mode,
        course_choice_id: current_candidate.application_choices.first.id,
        'return-to' => 'application-review',
      ),
    )
  end

  def when_i_click_back
    click_link 'Back'
  end

  def and_i_click_back
    when_i_click_back
  end

  def then_i_should_be_redirected_to_the_application_review_page
    expect(page).to have_current_path(candidate_interface_application_review_path)
  end

  def and_i_choose_a_course
    choose @provider.courses.second.name_and_code
    click_button t('continue')
  end

  def and_i_choose_part_time_study_mode
    choose 'Part time'
    click_button t('continue')
  end

  def when_i_update_the_course_to_a_course_with_two_available_study_modes
    when_i_click_change_course_choice
    choose @provider.courses.third.name_and_code
    click_button t('continue')
    choose 'Full time'
    click_button t('continue')
    choose @provider.courses.third.course_options.first.site.name
    click_button t('continue')
  end

  def when_i_update_the_study_mode_and_site
    when_i_click_change_study_mode
    choose 'Part time'
    click_button t('continue')
    choose @provider.courses.third.course_options.third.site.name
    click_button t('continue')
  end

  def when_i_update_the_site
    when_i_click_change_site
    choose @provider.courses.third.course_options.second.site.name
    click_button t('continue')
  end

  def and_i_should_see_the_updated_course_choice
    within('[data-qa="course-choice"]') do
      expect(page).to have_content @provider.courses.third.name.to_s
    end
  end

  def and_i_should_see_the_updated_study_mode_and_site
    within('[data-qa="course-choice-study-mode"]') do
      expect(page).to have_content 'Part time'
    end

    within('[data-qa="course-choice-location"]') do
      expect(page).to have_content @provider.courses.third.course_options.third.site.name.to_s
    end
  end

  def and_i_should_see_the_updated_course_site
    within('[data-qa="course-choice-location"]') do
      expect(page).to have_content @provider.courses.third.course_options.fourth.site.name.to_s
    end
  end
end
