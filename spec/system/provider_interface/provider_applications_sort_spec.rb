require 'rails_helper'

RSpec.feature 'Providers should be able to sort applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:tom_jones) { 'Tom Jones' }
  let(:adam_jones) { 'Adam Jones' }
  let(:jim_james) { 'Jim James' }
  let(:bill_bones) { 'Bill Bones' }


  let(:english) { 'English' }
  let(:alchemy) { 'Alchemy' }
  let(:divination) { 'Divination' }

  scenario 'by column headings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page
    then_i_should_see_the_applications_in_descending_date_order

    when_i_sort_by_date
    then_i_should_see_the_applications_in_ascending_date_order
    when_i_sort_by_date
    then_i_should_see_the_applications_in_descending_date_order

    when_i_sort_by_name
    then_i_should_see_the_applications_in_descending_name_order
    when_i_sort_by_name
    then_i_should_see_the_applications_in_ascending_name_order

    when_i_sort_by_course
    then_i_should_see_the_applications_in_descending_course_name_order
    when_i_sort_by_course
    then_i_should_see_the_applications_in_ascending_course_name_order
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

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_one, status: 'withdrawn', application_form:
           create(:application_form, first_name: 'Jim', last_name: 'James'), updated_at: 1.day.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Adam', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_two, status: 'offer', application_form:
           create(:application_form, first_name: 'Tom', last_name: 'Jones'), updated_at: 2.days.ago)

    create(:application_choice, :awaiting_provider_decision, course_option: course_option_three, status: 'declined', application_form:
           create(:application_form, first_name: 'Bill', last_name: 'Bones'), updated_at: 3.days.ago)
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def when_i_sort_by_date
    click_link('Last updated')
  end

  def then_i_should_see_the_applications_in_descending_date_order
    expect(jim_james).to appear_before(tom_jones)
    expect(tom_jones).to appear_before(bill_bones)
  end

  def then_i_should_see_the_applications_in_ascending_date_order
    expect(bill_bones).to appear_before(tom_jones)
    expect(tom_jones).to appear_before(jim_james)
  end

  def when_i_sort_by_name
    click_link('Name')
  end

  def then_i_should_see_the_applications_in_descending_name_order
    expect(tom_jones).to appear_before(adam_jones)
    expect(tom_jones).to appear_before(jim_james)
    expect(jim_james).to appear_before(bill_bones)
  end

  def then_i_should_see_the_applications_in_ascending_name_order
    expect(bill_bones).to appear_before(jim_james)
    expect(jim_james).to appear_before(tom_jones)
    expect(adam_jones).to appear_before(tom_jones)
  end

  def when_i_sort_by_course
    click_link('Course')
  end

  def then_i_should_see_the_applications_in_descending_course_name_order
    expect(english).to appear_before(divination)
    expect(divination).to appear_before(alchemy)
  end

  def then_i_should_see_the_applications_in_ascending_course_name_order
    expect(alchemy).to appear_before(divination)
    expect(divination).to appear_before(english)
  end
end
