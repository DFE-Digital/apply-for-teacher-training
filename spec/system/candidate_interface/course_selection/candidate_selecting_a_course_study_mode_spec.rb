require 'rails_helper'

RSpec.describe 'Selecting a study mode' do
  include CandidateHelper

  scenario 'Candidate selects different study modes' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options

    when_i_select_a_part_time_course
    then_i_can_only_select_sites_with_a_part_time_course

    when_i_select_a_site
    then_i_see_my_course_choice

    given_there_is_a_single_site_full_time_course_option
    when_i_select_the_single_site_full_time_course
    and_i_visit_my_course_choices_page
    then_the_site_is_resolved_automatically_and_i_see_the_course_choice
    and_the_application_is_not_school_placement_auto_selected
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'University of Alien Dance', selectable_school: true)

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

  def when_i_select_a_part_time_course
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select @provider.name
    click_link_or_button t('continue')

    choose @course.name
    click_link_or_button t('continue')

    click_link_or_button t('continue')
    expect(page).to have_text 'Select if the course is full time or part time'
    choose 'Part time'
    click_link_or_button t('continue')
  end

  def then_i_can_only_select_sites_with_a_part_time_course
    within '.govuk-radios' do
      radios = all('.govuk-radios__item')
      expect(radios.count).to eq 2
      expect(page).to have_text('Site 1')
      expect(page).to have_text('Site 2')
      expect(page).to have_no_text('Site 3')
    end
  end

  def when_i_select_a_site
    choose @first_site.name
    click_link_or_button t('continue')
  end

  def and_i_visit_my_course_choices_page
    visit candidate_interface_course_choices_course_review_path(@current_candidate.application_choices.last.id)
  end

  def then_i_see_my_course_choice
    expect(page).to have_text @course.name
    expect(page).to have_text 'Part time'
  end

  def given_there_is_a_single_site_full_time_course_option
    @single_site_course = create(
      :course,
      :with_both_study_modes,
      :open,
      provider: @provider,
      name: 'MS Painting',
    )

    create(
      :course_option,
      site: @first_site,
      course: @single_site_course,
      study_mode: :part_time,
    )

    create(
      :course_option,
      site: @first_site,
      course: @single_site_course,
      study_mode: :full_time,
    )
  end

  def when_i_select_the_single_site_full_time_course
    visit candidate_interface_application_choices_path
    click_link_or_button 'Add application'

    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')

    select @provider.name
    click_link_or_button t('continue')

    choose @single_site_course.name
    click_link_or_button t('continue')

    choose 'Full time'
    click_link_or_button t('continue')
  end

  def then_the_site_is_resolved_automatically_and_i_see_the_course_choice
    expect(page).to have_text @single_site_course.name
    expect(page).to have_text 'Full time'
  end

  def application_choice
    current_candidate.current_application.application_choices.last
  end

  def then_i_see_the_provider_name_in_caption
    expect(page.first('.govuk-caption-xl').text).to eq('University of Alien Dance')
  end

  def and_the_application_is_not_school_placement_auto_selected
    expect(page).to have_content('Location')
  end
end
