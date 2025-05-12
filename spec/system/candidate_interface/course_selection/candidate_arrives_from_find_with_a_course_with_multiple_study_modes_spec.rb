require 'rails_helper'

RSpec.describe 'Candidate arrives from Find with provider and course with multiple study modes' do
  include CandidateHelper

  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_signed_in_with_one_login

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_course_confirm_selection_page

    when_i_confirm_the_course
    then_i_am_redirect_to_the_course_study_mode_path

    then_i_see_the_provider_name_in_caption
    when_i_choose_the_study_mode
    then_i_am_redirected_to_the_course_site_path

    then_i_see_the_provider_name_in_caption

    when_i_choose_a_location
    then_i_am_redirected_to_the_course_review_path
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, name: 'Vim masters', selectable_school: true)

    @first_site = create(:site, provider: @provider, name: 'Site 1')
    @second_site = create(:site, provider: @provider, name: 'Site 2')
    @third_site = create(:site, provider: @provider, name: 'Site 3')

    @course = create(
      :course,
      :with_both_study_modes,
      :open,
      provider: @provider,
      name: 'Software Engineering',
    )

    create(
      :course_option,
      site: @first_site,
      course: @course,
      study_mode: :part_time,
    )
    create(
      :course_option,
      site: @second_site,
      course: @course,
      study_mode: :part_time,
    )
    create(
      :course_option,
      site: @third_site,
      course: @course,
      study_mode: :full_time,
    )
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

  def when_i_confirm_the_course
    choose 'Yes'
    click_link_or_button 'Continue'
  end

  def then_i_am_redirected_to_the_course_site_path
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_site_path(
        @provider.id,
        @course.id,
        'part_time',
      ),
    )
  end

  def when_i_choose_the_study_mode
    choose 'Part time'
    click_link_or_button t('continue')
  end

  def when_i_choose_a_location
    choose @second_site.name
    click_link_or_button t('continue')
  end

  def then_i_am_redirect_to_the_course_study_mode_path
    expect(page).to have_text 'Full time or part time?'
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_study_mode_path(@provider.id, @course.id),
    )
  end

  def then_i_am_redirected_to_the_course_review_path
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_path(application_choice_id: application_choice.id),
    )
  end

  def then_i_see_the_provider_name_in_caption
    expect(page.first('.govuk-caption-xl').text).to eq('Vim masters')
  end
end
