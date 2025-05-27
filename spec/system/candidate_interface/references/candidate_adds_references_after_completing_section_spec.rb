require 'rails_helper'

RSpec.describe 'Candidates adds references after marking section complete' do
  scenario 'section is set to incomplete' do
    given_i_am_signed_in
    and_i_have_completed_the_reference_section
    when_i_add_a_an_incomplete_reference
    then_the_section_is_marked_as_incomplete

    when_i_try_to_complete_the_section
    then_i_see_an_error
  end

private

  def and_i_have_completed_the_reference_section
    create_list(
      :reference,
      2,
      :not_requested_yet,
      application_form: @application_form,
      referee_type: 'professional',
    )
    @application_form.update(references_completed: true)
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application_form = @current_candidate.current_application
  end

  def when_i_add_a_an_incomplete_reference
    visit root_path
    click_on 'Your details'
    click_on 'References to be requested if you accept an offer'
    click_on 'Add another reference'
    choose 'Academic, such as a university tutor'
    click_on 'Continue'
    fill_in 'What’s the name of the person who can give a reference?', with: 'Reference 1'
    click_on 'Save and continue'
    # Now navigating away
    click_on 'Your details'
    click_on 'References to be requested if you accept an offer'
  end

  def then_the_section_is_marked_as_incomplete
    expect(@application_form.reload.references_completed).to be false
    expect(page).to have_content 'Reference 1'
    expect(page).to have_content 'Enter email address'
    expect(page).to have_content 'Enter how you know them and for how long'
    completed_section = find_field('Yes, I have completed this section').checked?
    expect(completed_section).to be false

    not_completed_section = find_field('No, I’ll come back to it later').checked?
    expect(not_completed_section).to be true
  end

  def when_i_try_to_complete_the_section
    choose 'Yes, I have completed this section'
    click_on 'Continue'
  end

  def then_i_see_an_error
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content 'Enter all required fields for each reference added'
    expect(page.title).to have_content 'Error:'
  end
end
