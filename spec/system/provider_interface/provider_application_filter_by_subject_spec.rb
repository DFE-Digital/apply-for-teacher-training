require 'rails_helper'

RSpec.describe 'Providers should be able to filter applications by subject', js: true do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:site) { build(:site, provider: current_provider) }

  let(:math) { create(:subject, name: 'Mathematics') }
  let!(:primary) { create(:subject, name: 'Primary') }
  let!(:primary_with_pe) { create(:subject, name: 'Primary with physical education') }
  let!(:primary_with_english) { create(:subject, name: 'Primary with English') }
  let!(:english) { create(:subject, name: 'English') }

  let(:primary_course) { create(:course, subjects: [primary, primary_with_pe], provider: current_provider) }
  let(:math_course) { create(:course, subjects: [math], provider: current_provider) }

  let(:course_option_math) { course_option_for_provider(provider: current_provider, site: site,  course: math_course) }
  let(:course_option_primary) { course_option_for_provider(provider: current_provider, site: site, course: primary_course) }

  let(:current_provider) { create(:provider, :with_signed_agreement, name: 'College of Dumbervale') }

  scenario 'can filter applications by status and provider' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications
    and_my_organisation_has_courses_with_applications
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_page

    when_i_filter_by_course_subjects_that_have_no_courses
    then_i_should_not_see_any_applications

    when_i_filter_by_course_subjects_related_to_courses
    then_i_should_see_applications_related_to_those_subjects

    when_i_click_to_remove_a_tag
    then_i_expect_that_tag_not_to_be_visible
    and_i_should_see_all_the_applications

    when_i_type_in_a_subject
    then_i_only_see_checkboxes_that_correspond_to_it
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications
    create(:provider_user, providers: [current_provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
  end

  def and_my_organisation_has_courses_with_applications
    @math_applications = create_list(:application_choice, 3, :awaiting_provider_decision, course_option: course_option_math)
    @primary_applications = create_list(:application_choice, 2, :awaiting_provider_decision, course_option: course_option_primary)
  end

  def when_i_filter_by_course_subjects_that_have_no_courses
    check 'English', visible: false
    click_on 'Apply filters'
  end

  def then_i_should_not_see_any_applications
    expect(page).to have_content('There are no results for the selected filter')
  end

  def when_i_filter_by_course_subjects_related_to_courses
    click_on 'Clear filters'

    check 'Mathematics', visible: false
    click_on 'Apply filters'
  end

  def then_i_should_see_applications_related_to_those_subjects
    @math_applications.each do |application|
      expect(page).to have_content(application.application_form.full_name)
    end
  end

  def when_i_click_to_remove_a_tag
    click_on 'Mathematics', match: :first
  end

  def then_i_expect_that_tag_not_to_be_visible
    expect(page).not_to have_css('.app-checkbox-filter__tag', text: 'Mathematics')
  end

  def and_i_should_see_all_the_applications
    expect(page).to have_content("Applications (#{(@math_applications + @primary_applications).count})")
  end

  def when_i_type_in_a_subject
    fill_in 'subject-checkbox-filter__filter-input', with: 'Prim'
  end

  def then_i_only_see_checkboxes_that_correspond_to_it
    checkboxes = all('.app-checkbox-filter__container .govuk-checkboxes__label', visible: true)

    expect(checkboxes.count).to eq(3)

    checkboxes.each do |element|
      expect(['Primary', 'Primary with English', 'Primary with physical education']).to include(element.text)
    end
  end
end
