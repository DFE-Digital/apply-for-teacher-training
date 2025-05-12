require 'rails_helper'

RSpec.describe 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:site) { build(:site, name: 'Test site name') }
  let(:site2) { build(:site, name: 'Second test site') }
  let(:site3) { build(:site, name: 'Second test site') }
  let(:site4) { build(:site, name: 'Second test site') }
  let(:site5) { build(:site, name: 'Second test site') }

  let(:current_provider) { create(:provider, name: 'Hoth Teacher Training', sites: [site, site2]) }
  let(:second_provider) { create(:provider, name: 'Caladan University', sites: [site3, site4]) }
  let(:third_provider) { create(:provider, name: 'University of Arrakis', sites: [site5]) }
  let(:accredited_provider1) { create(:provider, name: 'College of Dumbervale') }
  let(:accredited_provider2) { create(:provider, name: 'Wimleydown University') }

  scenario 'can filter applications by status and provider' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_filter_dialogue

    then_location_filters_are_not_visible

    then_i_can_see_applications_from_the_previous_year_too

    when_i_filter_for_rejected_applications
    then_only_rejected_applications_are_visible
    and_a_rejected_tag_is_visible
    and_the_rejected_tickbox_is_checked

    when_i_filter_for_applications_that_i_do_not_have
    then_i_see_the_no_filter_results_error_message
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_and_offered_applications
    then_only_rejected_and_offered_applications_are_visible

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible

    when_i_filter_by_providers
    then_location_filters_are_visible
    then_i_only_see_applications_for_a_given_provider
    then_i_expect_the_relevant_provider_tags_to_be_visible

    when_i_click_to_remove_a_tag
    then_i_expect_that_tag_not_to_be_visible
    and_the_remaining_filters_to_still_apply

    when_i_clear_the_filters
    and_i_filter_by_accredited_provider
    then_i_only_see_applications_for_a_given_accredited_provider
    then_i_expect_the_relevant_accredited_provider_tags_to_be_visible
    when_i_click_to_remove_an_accredited_provider_tag

    when_i_filter_by_providers
    then_i_see_locations_that_belong_to_all_of_the_selected_providers_that_have_more_than_one_site

    when_i_clear_the_filters
    when_i_filter_by_a_specific_provider
    then_i_only_see_locations_that_belong_to_that_provider

    when_i_filter_by_provider_location
    then_i_only_see_applications_for_that_provider_location
    and_i_expect_the_relevant_provider_location_tags_to_be_visible

    when_i_filter_by_recruitment_cycle
    then_i_only_see_applications_for_that_recruitment_cycle
    and_i_expect_the_relevant_recruitment_cycle_tags_to_be_visible

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible_again
    and_i_click_the_sign_out_button
  end

  scenario 'filter should not have accredited providers heading if none are available' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications_without_accredited_providers
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_i_do_not_expect_to_see_the_accredited_providers_filter_heading
    and_i_click_the_sign_out_button
  end

  scenario 'filters should persist across sessions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_by_providers
    then_i_only_see_applications_for_a_given_provider
    then_i_expect_the_relevant_provider_tags_to_be_visible

    and_i_click_the_sign_out_button
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_i_only_see_applications_for_a_given_provider
    then_i_expect_the_relevant_provider_tags_to_be_visible

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible_again
    and_i_click_the_sign_out_button
  end

  scenario 'when filtering by course type' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications_without_accredited_providers
    and_my_organisation_has_courses_that_awards_a_degree
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_teacher_degree_apprenticeship_filter_is_visible

    when_i_filter_by_postgraduate_courses
    then_i_only_see_postgraduate_applications

    when_i_filter_by_undergraduate_courses
    then_i_only_see_undergraduate_applications

    when_i_check_both_course_types_filter
    then_i_see_postgraduate_and_teacher_degree_apprenticeship_applications
  end

  def and_i_click_the_sign_out_button
    click_link_or_button 'Sign out'
  end

  def and_my_organisation_has_courses_with_applications_without_accredited_providers
    course_option_one = course_option_for_provider(provider: current_provider,
                                                   site:,
                                                   course: build(:course,
                                                                 name: 'Alchemy',
                                                                 provider: current_provider))

    course_option_two = course_option_for_provider(provider: second_provider, course: build(:course, name: 'Science', provider: second_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           build(:application_form, first_name: 'Greg', last_name: 'Taft'), updated_at: 4.days.ago)
  end

  def and_my_organisation_has_courses_that_awards_a_degree
    course_option_one = course_option_for_provider(provider: current_provider,
                                                   site:,
                                                   course: build(:course,
                                                                 :teacher_degree_apprenticeship,
                                                                 name: 'Alchemy',
                                                                 provider: current_provider))

    course_option_two = course_option_for_provider(provider: second_provider, course: build(:course, :teacher_degree_apprenticeship, name: 'Science', provider: second_provider))

    course_option_three = course_option_for_provider(provider: second_provider, course: build(:course, :teacher_degree_apprenticeship, name: 'Biology', provider: second_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Andres', last_name: 'Bartell'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           build(:application_form, first_name: 'Quinton', last_name: 'Marks'), updated_at: 4.days.ago)

    create(:application_choice, :awaiting_provider_decision, current_course_option: course_option_three, status: 'offer', application_form:
           build(:application_form, first_name: 'Leland', last_name: 'Harris'), updated_at: 4.days.ago)
  end

  def then_teacher_degree_apprenticeship_filter_is_visible
    expect(page).to have_content('Filter')
    expect(page).to have_content('Course type')
    expect(page).to have_content('Postgraduate courses')
    expect(page).to have_content('Undergraduate courses')
  end

  def then_i_do_not_expect_to_see_the_accredited_providers_filter_heading
    expect(page).to have_content('Filter')
    expect(page).to have_no_content('Accredited provider')
  end

  def then_i_see_locations_that_belong_to_all_of_the_selected_providers_that_have_more_than_one_site
    expect(page).to have_content('Locations for Hoth Teacher Training')
    expect(page).to have_content('Locations for Caladan University')
    expect(page).to have_no_content('Locations for University of Arrakis')
  end

  def then_i_only_see_locations_that_belong_to_that_provider
    expect(page).to have_no_content('Locations for Caladan University')
  end

  def then_location_filters_are_visible
    expect(page).to have_content('Locations for')
  end

  def then_location_filters_are_not_visible
    expect(page).to have_no_content('Locations for')
  end

  def then_i_only_see_applications_for_that_provider_location
    expect(page).to have_no_content('Adam Jones')
    expect(page).to have_no_content('Tom Jones')
    expect(page).to have_content('Jim James')
  end

  def when_i_filter_by_provider_location
    find_by_id("provider_location-#{site.provider_id}_#{site.name}_#{site.code}").set(true)
    and_i_apply_the_filters
  end

  def when_i_filter_by_postgraduate_courses
    check 'Postgraduate courses'
    and_i_apply_the_filters
  end

  def then_i_only_see_postgraduate_applications
    expect(page).to have_content('Jim James')
    expect(page).to have_content('Greg Taft')
    expect(page).to have_no_content('Andres Bartell')
    expect(page).to have_no_content('Quinton Marks')
    expect(page).to have_no_content('Leland Harris')
  end

  def when_i_filter_by_undergraduate_courses
    uncheck 'Postgraduate courses'
    check 'Undergraduate courses'
    and_i_apply_the_filters
  end

  def then_i_only_see_undergraduate_applications
    expect(page).to have_content('Andres Bartell')
    expect(page).to have_content('Quinton Marks')
    expect(page).to have_content('Leland Harris')
    expect(page).to have_no_content('Jim James')
    expect(page).to have_no_content('Greg Taft')
  end

  def when_i_check_both_course_types_filter
    check 'Postgraduate courses'
    check 'Undergraduate courses'
    and_i_apply_the_filters
  end

  def then_i_see_postgraduate_and_teacher_degree_apprenticeship_applications
    expect(page).to have_content('Andres Bartell')
    expect(page).to have_content('Undergraduate Quinton Marks')
    expect(page).to have_content('Undergraduate Leland Harris')
    expect(page).to have_content('Jim James')
    expect(page).to have_content('Greg Taft')
  end

  def and_i_expect_the_relevant_provider_location_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: site.name)
  end

  def when_i_filter_by_recruitment_cycle
    find(:css, "#recruitment_cycle_year-#{current_year}").set(true)
    click_link_or_button('Apply filters')
  end

  def then_i_only_see_applications_for_that_recruitment_cycle
    expect(page).to have_no_content('Anne Blast')
  end

  def and_i_expect_the_relevant_recruitment_cycle_tags_to_be_visible
    tag_text = "#{previous_year} to #{current_year}"
    expect(page).to have_css('.moj-filter-tags', text: tag_text)
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_from_multiple_providers
    provider_user_exists_in_apply_database_with_multiple_providers(providers: [current_provider, second_provider, third_provider])
  end

  def and_my_organisation_has_courses_with_applications
    course_option_one = course_option_for_provider(provider: current_provider,
                                                   site:,
                                                   course: build(:course,
                                                                 name: 'Alchemy',
                                                                 provider: current_provider,
                                                                 accredited_provider: accredited_provider1))

    course_option_two = course_option_for_provider(provider: current_provider, course: build(:course, name: 'Divination', provider: current_provider, accredited_provider: accredited_provider2))
    course_option_three = course_option_for_provider(provider: current_provider, course: build(:course, name: 'English', provider: current_provider))

    course_option_four = course_option_for_provider(provider: second_provider, course: build(:course, name: 'Science', provider: second_provider))
    course_option_five = course_option_for_provider(provider: second_provider, course: build(:course, name: 'History', provider: second_provider))

    course_option_six = course_option_for_provider(provider: third_provider, course: build(:course, name: 'Maths', provider: third_provider))
    course_option_seven = course_option_for_provider(provider: third_provider, course: build(:course, name: 'Engineering', provider: third_provider))
    course_option_from_previous_year = course_option_for_provider(provider: current_provider, course: build(:course, :previous_year, name: 'Engineering', provider: current_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           build(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'rejected', application_form:
           build(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           build(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_four, status: 'offer', application_form:
           build(:application_form, first_name: 'Greg', last_name: 'Taft'), updated_at: 4.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_five, status: 'rejected', application_form:
           build(:application_form, first_name: 'Paul', last_name: 'Atreides'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_six, status: 'withdrawn', application_form:
           build(:application_form, first_name: 'Duncan', last_name: 'Idaho'), updated_at: 6.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_seven, status: 'declined', application_form:
           build(:application_form, first_name: 'Luke', last_name: 'Smith'), updated_at: 7.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer_withdrawn', offer_withdrawn_at: 2.days.ago, application_form:
           build(:application_form, first_name: 'John', last_name: 'Smith'), updated_at: 8.days.ago)

    create(:application_choice, :offer, course_option: course_option_from_previous_year, status: 'offer', application_form:
           build(:application_form, first_name: 'Anne', last_name: 'Blast'), updated_at: 366.days.ago)
  end

  def then_i_can_see_applications_from_the_previous_year_too
    expect(page).to have_content('Anne Blast')
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_button('Apply filters')
  end

  def when_i_filter_for_rejected_applications
    find_by_id('status-rejected').set(true)
    click_link_or_button('Apply filters')
  end

  def then_only_rejected_applications_are_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_no_css('.app-application-cards', text: 'Offer')
    expect(page).to have_no_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).to have_no_css('.app-application-cards', text: 'Declined')
    expect(page).to have_no_css('.app-application-cards', text: 'Offer withdrawn')
  end

  def and_the_rejected_tickbox_is_checked
    rejected_checkbox = find_by_id('status-rejected')
    expect(rejected_checkbox.checked?).to be(true)
  end

  def when_i_filter_for_applications_that_i_do_not_have
    find_by_id('status-rejected').set(false)
    find_by_id('status-pending_conditions').set(true)
    click_link_or_button('Apply filters')
  end

  def then_i_see_the_no_filter_results_error_message
    expect(page).to have_content('There are no results for the selected filter.')
  end

  def when_i_filter_for_rejected_and_offered_applications
    find_by_id('status-pending_conditions').set(false)
    find_by_id('status-rejected').set(true)
    find_by_id('status-offer').set(true)
    click_link_or_button('Apply filters')
  end

  def then_only_rejected_and_offered_applications_are_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).to have_no_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).to have_no_css('.app-application-cards', text: 'Declined')
  end

  def when_i_clear_the_filters
    click_link_or_button('Clear filters')
  end

  def then_i_expect_all_applications_to_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).to have_css('.app-application-cards', text: 'Declined')
  end

  def when_i_filter_by_providers
    find(:css, "#provider-#{current_provider.id}").set(true)
    find(:css, "#provider-#{second_provider.id}").set(true)
    click_link_or_button('Apply filters')
  end

  def when_i_filter_by_a_specific_provider
    find(:css, "#provider-#{current_provider.id}").set(true)
    click_link_or_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_provider
    expect(page).to have_css('.app-application-cards', text: 'Hoth Teacher Training')
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
    expect(page).to have_no_css('.app-application-cards', text: 'University of Arrakis')
  end

  def and_i_filter_by_accredited_provider
    find(:css, "#accredited_provider-#{accredited_provider2.id}").set(true)
    click_link_or_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_accredited_provider
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).to have_no_content('Jim James')
  end

  def then_i_expect_the_relevant_accredited_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Wimleydown University')
    expect(page).to have_no_css('.moj-filter-tags', text: 'College of Dumbervale')
  end

  def then_i_expect_the_relevant_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def when_i_click_to_remove_a_tag
    click_link_or_button('Hoth Teacher Training')
  end

  def then_i_expect_that_tag_not_to_be_visible
    expect(page).to have_no_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def and_the_remaining_filters_to_still_apply
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
  end

  def and_a_rejected_tag_is_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Rejected')
  end

  def when_i_click_to_remove_an_accredited_provider_tag
    click_link_or_button('Wimleydown University')
  end

  def then_i_expect_all_applications_to_be_visible_again
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).to have_content('Jim James')
  end

  def and_i_apply_the_filters
    click_link_or_button('Apply filters')
  end
end
