require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course params' do
  include CandidateHelper

  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    and_the_pilot_is_open

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_signed_in

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_course_confirm_selection_page
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5')
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions', provider: @provider)
  end

  def and_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path(providerCode: @course.provider.code, courseCode: @course.code)
  end

  def then_i_am_redirected_to_the_create_account_or_sign_in_path
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(providerCode: @provider.code, courseCode: @course.code)
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def then_i_am_redirected_to_the_course_confirm_selection_page
    expect(page).to have_current_path candidate_interface_course_confirm_selection_path(@course.id)
  end
end
