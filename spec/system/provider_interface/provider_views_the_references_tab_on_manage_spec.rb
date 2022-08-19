require 'rails_helper'

RSpec.feature 'Provider views an application in new cycle' do
  include CandidateHelper
  include CycleTimetableHelper
  include CourseOptionHelpers
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(CycleTimetable.apply_opens(2023) + 1.day) do
      example.run
    end
  end

  scenario 'Provider views the new references tab' do
    given_the_new_reference_flow_feature_flag_is_on

    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_applications
    and_i_sign_in_to_the_provider_interface
    then_i_should_see_the_applications_from_my_organisation

    when_i_click_on_an_application
    then_i_should_be_on_the_application_view_page

    when_i_click_on_the_references_tab
    then_i_see_the_candidates_references
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow_providers)
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in

    provider_user = provider_user_exists_in_apply_database
    create(:provider, :with_signed_agreement, code: 'ABC', provider_users: [provider_user])
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')

    @my_provider_choice = create(:submitted_application_choice,
                                 :with_completed_application_form,
                                 status: 'awaiting_provider_decision',
                                 course_option: course_option)

    @my_provider_choice.application_form.application_references.update(feedback_status: 'feedback_requested')
  end

  def then_i_should_see_the_applications_from_my_organisation
    expect(page).to have_title 'Applications (1)'
    expect(page).to have_content 'Applications (1)'
    expect(page).to have_content @my_provider_choice.application_form.full_name
  end

  def when_i_click_on_an_application
    click_on @my_provider_choice.application_form.full_name
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content @my_provider_choice.id

    expect(page).to have_content @my_provider_choice.application_form.full_name
  end

  def when_i_click_on_the_references_tab
    click_on 'References'
  end

  def then_i_see_the_candidates_references
    references = @my_provider_choice.application_form.application_references
    link = page.find_link('References', class: 'app-tab-navigation__link')
    expect(link['aria-current']).to eq('page')

    expect(page).to have_content 'The candidate has received 2 references'
    expect(page).to have_content "#{references.first.referee_type.humanize} reference from #{references.first.name}"
    expect(page).to have_content "#{references.second.referee_type.humanize} reference from #{references.second.name}"
  end
end
