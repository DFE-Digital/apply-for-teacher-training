require 'rails_helper'

RSpec.describe 'Provider onboarding monitoring page' do
  include DfESignInHelpers

  it 'rendering the page' do
    given_i_am_a_support_user

    and_there_is_a_provider_with_no_users
    and_there_is_a_provider_with_users_that_have_never_signed_in
    and_there_is_a_provider_who_has_not_set_up_relationship_permissions
    and_there_is_a_provider_who_has_not_made_a_decision_in_the_last_7_days

    and_i_visit_the_provider_onboarding_page

    then_i_see_the_provider_with_no_users
    and_i_see_the_provider_with_users_that_have_never_signed_in
    and_i_see_the_provider_who_has_not_set_up_relationship_permissions
    and_i_see_the_provider_who_has_not_made_a_decision_in_the_last_7_days
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_visit_the_provider_onboarding_page
    visit '/support/provider-onboarding'
  end

  def and_there_is_a_provider_with_no_users
    provider = create(:provider, :no_users, name: 'No users')
    create(:course, provider:)
  end

  def and_there_is_a_provider_with_users_that_have_never_signed_in
    provider = create(:provider, name: 'Users have not signed in')
    create(:provider_user, providers: [provider], last_signed_in_at: nil)
    create(:course, provider:)
  end

  def and_there_is_a_provider_who_has_not_set_up_relationship_permissions
    provider = create(:provider, name: 'Relationships not set up')
    create(:provider_user, providers: [provider], last_signed_in_at: 1.day.ago)
    create(:provider_relationship_permissions, :with_open_course, :not_set_up_yet, training_provider: provider)
    create(:provider_relationship_permissions, :with_open_course, ratifying_provider: provider)
  end

  def and_there_is_a_provider_who_has_not_made_a_decision_in_the_last_7_days
    provider = create(:provider, :with_vendor, name: 'No decisions made')
    create(:provider_user, providers: [provider], last_signed_in_at: 1.day.ago)
    course = create(:course, :with_course_options, :open, provider:)

    create(:application_choice, course:, offered_at: 8.days.ago)
    create(:application_choice, :rejected_by_default, course:, rejected_at: 1.day.ago)
  end

  def then_i_see_the_provider_with_no_users
    within('[data-qa="no-users"]') do
      expect(page).to have_link 'No users'
    end
  end

  def and_i_see_the_provider_with_users_that_have_never_signed_in
    within('[data-qa="no-users-logged-in"]') do
      expect(page).to have_link 'Users have not signed in'
    end
  end

  def and_i_see_the_provider_who_has_not_set_up_relationship_permissions
    within('[data-qa="permissions-not-set-up"]') do
      expect(page).to have_content 'Relationships not set up'
    end
  end

  def and_i_see_the_provider_who_has_not_made_a_decision_in_the_last_7_days
    within('[data-qa="no-decisions"]') do
      expect(page).to have_content 'No decisions made'
    end
  end
end
