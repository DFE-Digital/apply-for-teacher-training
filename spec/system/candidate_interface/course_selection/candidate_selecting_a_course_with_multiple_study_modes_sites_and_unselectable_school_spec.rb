require 'rails_helper'

RSpec.describe 'Selecting a course with multiple study modes and sites when the provider is not selectable_school' do
  include CandidateHelper

  it 'Candidate skips the school selection', time: CycleTimetableHelper.mid_cycle(2025) do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices

    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_click_continue
    and_i_choose_a_provider
    and_i_choose_a_course
    and_i_choose_part_time

    then_i_am_on_the_application_choice_review_page
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    and_i_click_continue
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_that_i_know_where_i_want_to_apply
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def and_i_choose_a_course
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end

  def and_i_choose_part_time
    choose 'Part time'
    click_link_or_button t('continue')
  end

  def when_i_click_continue
    click_link_or_button t('continue')
  end

  def and_i_click_continue
    when_i_click_continue
  end

  def application_choice
    current_candidate.current_application.application_choices.last
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', selectable_school: false)
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
    @multi_site_course = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: first_site, course: @multi_site_course, study_mode: :part_time)
    create(:course_option, site: first_site, course: @multi_site_course, study_mode: :full_time)
    create(:course_option, site: second_site, course: @multi_site_course, study_mode: :part_time)
    create(:course_option, site: second_site, course: @multi_site_course, study_mode: :full_time)
  end
end
