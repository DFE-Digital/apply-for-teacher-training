require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course params' do
  scenario 'The provider is only accepting applications on the Apply service' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5')
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions', provider: @provider)
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path(providerCode: @course.provider.code, courseCode: @course.code)
  end

  def then_i_am_redirected_to_the_create_account_or_sign_in_path
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(providerCode: @provider.code, courseCode: @course.code)
  end
end
