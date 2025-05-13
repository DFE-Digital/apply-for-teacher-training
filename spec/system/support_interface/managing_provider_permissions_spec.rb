require 'rails_helper'

RSpec.describe 'Managing provider-provider permissions via support' do
  include DfESignInHelpers

  scenario 'Support user changes provider permissions' do
    given_i_am_a_support_user
    and_there_are_two_providers_in_a_partnership

    when_i_visit_the_first_provider
    and_click_relationships
    and_set_invalid_relationships
    then_i_see_an_error

    when_i_set_valid_relationships
    then_the_relationships_have_been_updated
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_two_providers_in_a_partnership
    training = create(:provider, name: 'Numan College')
    ratifying = create(:provider, name: 'Oldman University')

    create(:provider_relationship_permissions, :not_set_up_yet,
           training_provider: training, ratifying_provider: ratifying)
  end

  def when_i_visit_the_first_provider
    click_link_or_button 'Providers'
    click_link_or_button 'Numan College'
  end

  def and_click_relationships
    click_link_or_button 'Relationships'
  end

  def and_set_invalid_relationships
    # check no checkboxes

    click_link_or_button 'Update relationships'
  end

  def then_i_see_an_error
    expect(page).to have_content 'Select who can send offers, invitations and rejections'
  end

  def when_i_set_valid_relationships
    all('input[type=checkbox]').each do |checkbox|
      if !checkbox.checked?
        checkbox.click
      end
    end

    click_link_or_button 'Update relationships'
  end

  def then_the_relationships_have_been_updated
    expect(page).to have_content 'Relationships updated'

    checkboxes = all('input[type=checkbox]')
    expect(checkboxes.count).to eq 6
    expect(checkboxes).to all be_checked
  end
end
