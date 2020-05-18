require 'rails_helper'

RSpec.feature 'Providers should be able to filter applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'can filter applications by status and provider' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_from_multiple_providers
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_applications
    then_only_rejected_applications_should_be_visible
    and_a_rejected_tag_should_be_visible
    and_the_rejected_tickbox_should_still_be_checked

    when_i_filter_for_applications_that_i_do_not_have
    then_i_should_see_the_no_filter_results_error_message
    then_i_expect_to_see_the_filter_dialogue

    when_i_filter_for_rejected_and_offered_applications
    then_only_rejected_and_offered_applications_should_be_visible

    when_i_clear_the_filters
    then_i_expect_all_applications_to_be_visible

    when_i_filter_by_provider
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
    then_i_expect_all_applications_to_be_visible_again
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_from_multiple_providers
    provider_user_exists_in_apply_database_with_multiple_providers
  end

  def and_my_organisation_has_courses_with_applications
    current_provider = create(:provider, :with_signed_agreement, code: 'ABC', name: 'Hoth Teacher Training')
    second_provider = create(:provider, :with_signed_agreement, code: 'DEF', name: 'Caladan University')
    third_provider = create(:provider, :with_signed_agreement, code: 'GHI', name: 'University of Arrakis')

    accredited_provider1 = create(:provider, code: 'JKL', name: 'College of Dumbervale')
    accredited_provider2 = create(:provider, code: 'MNO', name: 'Wimleydown University')

    course_option_one = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Alchemy', provider: current_provider, accredited_provider: accredited_provider1))
    course_option_two = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Divination', provider: current_provider, accredited_provider: accredited_provider2))
    course_option_three = course_option_for_provider(provider: current_provider, course: create(:course, name: 'English', provider: current_provider))

    course_option_four = course_option_for_provider(provider: second_provider, course: create(:course, name: 'Science', provider: second_provider))
    course_option_five = course_option_for_provider(provider: second_provider, course: create(:course, name: 'History', provider: second_provider))

    course_option_six = course_option_for_provider(provider: third_provider, course: create(:course, name: 'Maths', provider: third_provider))
    course_option_seven = course_option_for_provider(provider: third_provider, course: create(:course, name: 'Engineering', provider: third_provider))

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'rejected', application_form:
           create(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           create(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_four, status: 'offer', application_form:
           create(:application_form, first_name: 'Greg', last_name: 'Taft'), updated_at: 4.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_five, status: 'rejected', application_form:
           create(:application_form, first_name: 'Paul', last_name: 'Atreides'), updated_at: 5.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_six, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Duncan', last_name: 'Idaho'), updated_at: 6.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_seven, status: 'declined', application_form:
           create(:application_form, first_name: 'Luke', last_name: 'Smith'), updated_at: 7.days.ago)
  end

  def then_i_expect_to_see_the_filter_dialogue
    expect(page).to have_button('Apply filters')
  end

  def when_i_filter_for_rejected_applications
    find(:css, '#status-rejected').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_applications_should_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).not_to have_css('.app-application-cards', text: 'Offer')
    expect(page).not_to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).not_to have_css('.app-application-cards', text: 'Declined')
  end

  def and_the_rejected_tickbox_should_still_be_checked
    rejected_checkbox = find(:css, '#status-rejected')
    expect(rejected_checkbox.checked?).to be(true)
  end

  def when_i_filter_for_applications_that_i_do_not_have
    find(:css, '#status-rejected').set(false)
    find(:css, '#status-accepted').set(true)
    click_button('Apply filters')
  end

  def then_i_should_see_the_no_filter_results_error_message
    expect(page).to have_content('No applications for the selected filters.')
  end

  def when_i_filter_for_rejected_and_offered_applications
    find(:css, '#status-accepted').set(false)
    find(:css, '#status-rejected').set(true)
    find(:css, '#status-offered').set(true)
    click_button('Apply filters')
  end

  def then_only_rejected_and_offered_applications_should_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).not_to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).not_to have_css('.app-application-cards', text: 'Declined')
  end

  def when_i_clear_the_filters
    click_link('Clear')
  end

  def then_i_expect_all_applications_to_be_visible
    expect(page).to have_css('.app-application-cards', text: 'Rejected')
    expect(page).to have_css('.app-application-cards', text: 'Offer')
    expect(page).to have_css('.app-application-cards', text: 'Application withdrawn')
    expect(page).to have_css('.app-application-cards', text: 'Declined')
  end

  def when_i_filter_by_provider
    find(:css, '#provider-hoth-teacher-training').set(true)
    find(:css, '#provider-caladan-university').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_provider
    expect(page).to have_css('.app-application-cards', text: 'Hoth Teacher Training')
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
    expect(page).not_to have_css('.app-application-cards', text: 'University of Arrakis')
  end

  def and_i_filter_by_accredited_provider
    find(:css, '#accredited_provider-wimleydown-university').set(true)
    click_button('Apply filters')
  end

  def then_i_only_see_applications_for_a_given_accredited_provider
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).not_to have_content('Jim James')
  end

  def then_i_expect_the_relevant_accredited_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Wimleydown University')
    expect(page).not_to have_css('.moj-filter-tags', text: 'College of Dumbervale')
  end

  def then_i_expect_the_relevant_provider_tags_to_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def when_i_click_to_remove_a_tag
    click_link('Hoth Teacher Training')
  end

  def then_i_expect_that_tag_not_to_be_visible
    expect(page).not_to have_css('.moj-filter-tags', text: 'Hoth Teacher Training')
    expect(page).to have_css('.moj-filter-tags', text: 'Caladan University')
  end

  def and_the_remaining_filters_to_still_apply
    expect(page).to have_css('.app-application-cards', text: 'Caladan University')
  end

  def and_a_rejected_tag_should_be_visible
    expect(page).to have_css('.moj-filter-tags', text: 'Rejected')
  end

  def when_i_click_to_remove_an_accredited_provider_tag
    click_link('Wimleydown University')
  end

  def then_i_expect_all_applications_to_be_visible_again
    expect(page).to have_content('Adam Jones')
    expect(page).to have_content('Tom Jones')
    expect(page).to have_content('Jim James')
  end
end
