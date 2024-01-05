require 'rails_helper'

RSpec.feature 'Providers should be able to sort applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'viewing applications one page at a time' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_fewer_than_30_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_applications_page
    then_i_should_not_see_a_paginator

    given_my_organisation_has_more_than_30_applications
    when_i_visit_the_provider_applications_page
    then_i_should_see_a_paginator

    when_i_click_next
    then_i_should_see_page_2
    then_i_should_see_a_paginator_for_page_2
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_fewer_than_30_applications
    @provider = @provider_user.providers.first
    @course_option_one = course_option_for_provider(provider: @provider, course: create(:course, name: 'Alchemy', provider: @provider))
    @course_option_two = course_option_for_provider(provider: @provider, course: create(:course, name: 'Divination', provider: @provider))
    @course_option_three = course_option_for_provider(provider: @provider, course: create(:course, name: 'English', provider: @provider))

    create(:application_choice, :awaiting_provider_decision, course_option: @course_option_one, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: @course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: @course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: @course_option_three, status: 'declined', application_form:
           create(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)
  end

  def when_i_visit_the_provider_applications_page
    visit provider_interface_applications_path
  end

  def then_i_should_not_see_a_paginator
    expect(page).to have_no_link('Next')
    expect(page).to have_no_content('Showing 1 to')
  end

  def given_my_organisation_has_more_than_30_applications
    30.times do |_n|
      create(:application_choice,
             :awaiting_provider_decision,
             course_option: course_option_for_provider(
               provider: @provider,
               course: create(:course, name: 'Alchemy', provider: @provider),
             ),
             application_form: create(:application_form),
             updated_at: 1.day.ago)
    end
  end

  def then_i_should_see_a_paginator
    expect(page).to have_link('Next')
    expect(page).to have_link('2')
    expect(page).to have_content('Showing 1 to')
  end

  def when_i_click_next
    click_link 'Next'
  end

  def then_i_should_see_page_2
    expect(page).to have_current_path(provider_interface_applications_path(page: '2'))
  end

  def when_i_click_prev
    click_link 'Previous'
  end

  def then_i_should_see_a_paginator_for_page_2
    expect(page).to have_link('Previous')
    expect(page).to have_link('1')
    expect(page).to have_content('Showing 31 to')
  end

  def then_i_should_not_see_a_paginator
    expect(page).to have_no_link('Next')
    expect(page).to have_no_content('Showing 1 to')
  end
end
