require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course params', :continuous_applications do
  include CandidateHelper

  scenario 'The candidate has hit the maximum amount of unsuccessful choices per cycle' do
    given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply

    when_i_follow_a_link_from_find
    then_i_am_redirected_to_the_create_account_or_sign_in_path

    given_i_am_at_the_maximum_limit_of_unsuccessful_applications

    when_i_follow_a_link_from_find
    then_i_am_presented_with_an_error_message
  end

  def given_there_is_a_provider_with_a_course_that_is_only_accepting_applications_on_apply
    @provider = create(:provider, code: '8N5')
    @course = create(:course, :open_on_apply, name: 'Potions', provider: @provider)
  end

  def when_i_follow_a_link_from_find
    visit candidate_interface_apply_from_find_path(providerCode: @course.provider.code, courseCode: @course.code)
  end

  def then_i_am_redirected_to_the_create_account_or_sign_in_path
    expect(page).to have_current_path candidate_interface_create_account_or_sign_in_path(providerCode: @provider.code, courseCode: @course.code)
  end

  def given_i_am_at_the_maximum_limit_of_unsuccessful_applications
    create_and_sign_in_candidate
    current_candidate.application_forms << build(:application_form, :completed)
    current_candidate.current_application.application_choices << build_list(:application_choice, 15, :withdrawn)
  end

  def then_i_am_presented_with_an_error_message
    expect(page).to have_content I18n.t('errors.messages.too_many_unsuccessful_choices', max_unsuccessful_applications: ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS)
  end
end
