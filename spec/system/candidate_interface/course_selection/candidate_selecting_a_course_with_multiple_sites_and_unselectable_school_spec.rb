require 'rails_helper'

RSpec.describe 'Selecting a course with multiple sites when the provider is not selectable_school', time: CycleTimetableHelper.mid_cycle(2025) do
  include CandidateHelper

  describe 'when there is a main site' do
    it 'Candidate skips the school selection, main site is selected automatically' do
      given_i_am_signed_in_with_one_login
      and_there_are_course_options

      when_i_visit_the_site
      and_i_click_on_course_choices

      and_i_choose_that_i_know_where_i_want_to_apply
      and_i_click_continue
      and_i_choose_a_provider
      and_i_choose_a_course

      then_i_am_on_the_application_choice_review_page
      and_the_application_is_school_placement_auto_selected
      and_the_site_is_the_main_site
    end
  end

  describe 'when there is no main site' do
    it 'Candidate skips the school selection, first site is selected automatically' do
      given_i_am_signed_in_with_one_login
      and_there_are_course_options_without_main_site

      when_i_visit_the_site
      and_i_click_on_course_choices

      and_i_choose_that_i_know_where_i_want_to_apply
      and_i_click_continue
      and_i_choose_a_provider
      and_i_choose_a_course

      then_i_am_on_the_application_choice_review_page
      and_the_application_is_school_placement_auto_selected
      and_the_site_is_the_first_site
    end
  end

  describe 'when there is a main site and course option has study modes' do
    it 'Candidate skips the school selection, main site is selected automatically' do
      given_i_am_signed_in_with_one_login
      and_there_are_course_options_with_study_modes

      when_i_visit_the_site
      and_i_click_on_course_choices

      and_i_choose_that_i_know_where_i_want_to_apply
      and_i_click_continue
      and_i_choose_a_provider
      and_i_choose_a_course
      and_i_choose_full_time

      then_i_am_on_the_application_choice_review_page
      and_the_application_is_school_placement_auto_selected
      and_the_site_is_the_main_site
    end
  end

  describe 'when there is no main site and course option has study modes' do
    it 'Candidate skips the school selection, first site is selected automatically' do
      given_i_am_signed_in_with_one_login
      and_there_are_course_options_without_main_site_with_study_modes

      when_i_visit_the_site
      and_i_click_on_course_choices

      and_i_choose_that_i_know_where_i_want_to_apply
      and_i_click_continue
      and_i_choose_a_provider
      and_i_choose_a_course
      and_i_choose_full_time

      then_i_am_on_the_application_choice_review_page
      and_the_application_is_school_placement_auto_selected
      and_the_site_is_the_first_site
    end
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

  def and_i_choose_full_time
    choose 'Full time'
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

  def and_there_are_course_options_without_main_site
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', selectable_school: false)
    first_site = create(
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
    second_site = create(
      :site,
      name: 'Another site',
      code: 'ABC',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    @multi_site_course = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: first_site, course: @multi_site_course)
    create(:course_option, site: second_site, course: @multi_site_course)
  end

  def and_there_are_course_options_without_main_site_with_study_modes
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', selectable_school: false)
    first_site = create(
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
    second_site = create(
      :site,
      name: 'Another site',
      code: 'ABC',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    @multi_site_course = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: first_site, course: @multi_site_course)
    create(:course_option, :full_time, site: second_site, course: @multi_site_course)
    create(:course_option, :part_time, site: second_site, course: @multi_site_course)
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', selectable_school: false)
    first_site = create(
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
    second_site = create(
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
    @multi_site_course = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: first_site, course: @multi_site_course)
    create(:course_option, site: second_site, course: @multi_site_course)
  end

  def and_there_are_course_options_with_study_modes
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1', selectable_school: false)
    first_site = create(
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
    second_site = create(
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
    @multi_site_course = create(:course, :open, :with_both_study_modes, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site: first_site, course: @multi_site_course)
    create(:course_option, :full_time, site: second_site, course: @multi_site_course)
    create(:course_option, :part_time, site: second_site, course: @multi_site_course)
  end

  def and_the_application_is_school_placement_auto_selected
    expect(page).to have_no_content('Location')
  end

  def and_the_site_is_the_main_site
    expect(application_choice.current_course_option.site.main_site?).to be true
  end

  def and_the_site_is_the_first_site
    expect(application_choice.current_course_option.site.main_site?).to be false
    expect(application_choice.current_course_option.site.code).to eq '1'
  end
end
