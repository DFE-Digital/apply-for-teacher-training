require 'rails_helper'

RSpec.feature 'Providers should be able to sort applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'by sort options' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_i_should_see_the_applications_in_descending_date_order
    and_the_sorted_by_option_should_be_present

    when_i_sort_by_days_left_to_respond
    then_i_should_see_the_applications_in_descending_reject_by_default_date_order
  end

  def and_the_sorted_by_option_should_be_present
    expect(page).to have_select(:sort_by, selected: 'Last changed')
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_courses_with_applications
    current_provider = create(:provider, :with_signed_agreement, code: 'ABC')

    course_option_one = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Alchemy', provider: current_provider))
    course_option_two = course_option_for_provider(provider: current_provider, course: create(:course, name: 'Divination', provider: current_provider))
    course_option_three = course_option_for_provider(provider: current_provider, course: create(:course, name: 'English', provider: current_provider))

    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_one,
      application_form: create(:application_form, first_name: 'Jim', last_name: 'James'),
      reject_by_default_at: 1.day.from_now,
      updated_at: 1.day.ago,
    )

    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_two,
      application_form: create(:application_form, first_name: 'Adam', last_name: 'Jones'),
      reject_by_default_at: 5.days.from_now,
      updated_at: 2.days.ago,
    )

    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_two,
      application_form: create(:application_form, first_name: 'Tom', last_name: 'Jones'),
      reject_by_default_at: 10.days.from_now,
      updated_at: 2.days.ago,
    )

    create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: course_option_three,
      application_form: create(:application_form, first_name: 'Bill', last_name: 'Bones'),
      reject_by_default_at: 1.day.ago,
      updated_at: 3.days.ago,
    )
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  # rubocop:disable RSpec/ExpectActual
  def then_i_should_see_the_applications_in_descending_date_order
    expect('Jim James').to appear_before('Tom Jones')
    expect('Tom Jones').to appear_before('Bill Bones')
  end
  # rubocop:enable RSpec/ExpectActual

  def when_i_sort_by_days_left_to_respond
    select 'Days left to respond', from: :sort_by
    click_on 'Sort'
  end

  def then_i_should_see_the_applications_in_descending_reject_by_default_date_order
    cards = all('.app-application-card')

    within(cards[0]) do
      expect(page).to have_content('Jim James')
      expect(page).to have_content('1 day to respond')
    end

    within(cards[1]) do
      expect(page).to have_content('Adam Jones')
      expect(page).to have_content('5 days to respond')
    end

    within(cards[2]) do
      expect(page).to have_content('Tom Jones')
      expect(page).to have_content('10 days to respond')
    end

    within(cards[3]) do
      expect(page).to have_content('Bill Bones')
      expect(page).to have_content(3.days.ago.to_s(:govuk_date))
    end
  end
end
