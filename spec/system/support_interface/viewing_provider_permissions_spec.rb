require 'rails_helper'

RSpec.feature 'Viewing provider-provider permissions via support' do
  include DfESignInHelpers

  scenario 'Support user views provider permissions via users page' do
    given_i_am_a_support_user
    and_there_are_two_providers_in_a_partnership
    and_there_are_two_other_providers_in_a_partnership_with_no_permissions_configured

    when_i_visit_the_training_provider
    and_click_users
    then_i_should_see_the_training_provider_permissions_diagram

    when_i_visit_the_ratifying_provider
    and_click_users
    then_i_should_see_the_ratifying_provider_permissions_diagram

    when_i_visit_the_ratifying_provider_with_no_permissions
    and_click_users
    then_i_should_clearly_see_that_no_permissions_have_been_setup
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_two_providers_in_a_partnership
    training = create(:provider, :with_signed_agreement, name: 'Numan College')
    ratifying = create(:provider, :with_signed_agreement, name: 'Oldman University')

    create(
      :provider_relationship_permissions,
      training_provider: training,
      ratifying_provider: ratifying,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_diversity_information: true,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: true,
      training_provider_can_view_diversity_information: false,
    )
  end

  def and_there_are_two_other_providers_in_a_partnership_with_no_permissions_configured
    training = create(:provider, :with_signed_agreement, name: 'City Learning Trust')
    ratifying = create(:provider, :with_signed_agreement, name: 'Staffordshire University (S72)')

    create(
      :provider_relationship_permissions,
      :not_set_up_yet,
      training_provider: training,
      ratifying_provider: ratifying,
    )
  end

  def when_i_visit_the_training_provider
    click_on 'Providers'
    click_on 'Numan College'
  end

  def and_click_users
    click_on 'Users'
  end

  def then_i_should_see_the_training_provider_permissions_diagram
    expect(page).to have_content 'can ✅ view safeguarding ❌ view diversity ❌ make decisions for courses ratified by'
  end

  def when_i_visit_the_ratifying_provider
    visit '/support'
    click_on 'Providers'
    click_on 'Oldman University'
  end

  def then_i_should_see_the_ratifying_provider_permissions_diagram
    expect(page).to have_content 'can ❌ view safeguarding ✅ view diversity ✅ make decisions for courses run by'
  end

  def when_i_visit_the_ratifying_provider_with_no_permissions
    visit '/support'
    click_on 'Providers'
    click_on 'Staffordshire University (S72)'
  end

  def then_i_should_clearly_see_that_no_permissions_have_been_setup
    expect(page).to have_content 'Permissions not setup'
  end
end
