require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course with multiple sites' do
  include CandidateHelper

  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_signed_in

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_course_confirm_selection_page

    when_i_confirm_the_course
    then_i_should_be_redirected_to_the_course_site_path

    when_i_choose_a_location
    then_i_should_be_redirected_to_the_course_review_path
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5', name: 'Snape University')
    @course = create(:course, :open_on_apply, name: 'Potions', provider: @provider, recruitment_cycle_year: 2024)
    first_site = create(
      :site,
      name: 'Main site',
      code: '-',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    second_site = create(
      :site,
      name: 'Harehills Primary School',
      code: '1',
      provider: @provider,
      address_line1: 'Darfield Road',
      address_line2: '',
      address_line3: 'Leeds',
      address_line4: 'West Yorkshire',
      postcode: 'LS8 5DQ',
    )
    create(:course_option, site: first_site, course: @course)
    create(:course_option, site: second_site, course: @course)
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

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_am_redirected_to_the_course_confirm_selection_page
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_course_confirm_selection_path(@course.id),
    )
  end

  def when_i_confirm_the_course
    choose 'Yes'
    click_link_or_button 'Continue'
  end

  def then_i_should_be_redirected_to_the_course_site_path
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_course_site_path(
        @provider.id,
        @course.id,
        'full_time',
      ),
    )
  end

  def when_i_choose_a_location
    choose 'Main site'
    click_link_or_button t('continue')
  end

  def then_i_should_be_redirected_to_the_course_review_path
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_course_review_path(application_choice_id: application_choice.id),
    )
  end
end
