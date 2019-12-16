require 'rails_helper'

RSpec.feature 'Send chase email to referee and candidate' do
  include DfESignInHelpers

  scenario 'Support agent sends a chase email to a referee and candidate' do
    given_i_am_a_support_user
    and_there_is_an_application_awaiting_references
    and_i_visit_the_support_page

    when_i_click_on_the_application_awaiting_references
    then_i_should_be_on_the_view_application_page

    when_i_click_on_chase_reference
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_sending_the_chase_email
    then_i_see_the_referee_email_is_successfully_sent
    and_i_see_the_candidate_email_is_successfully_sent
    and_i_am_sent_back_to_the_application_form_with_a_flash
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_awaiting_references
    @application_awaiting_references = create(:completed_application_form)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application_awaiting_references
    click_on @application_awaiting_references.candidate.email_address
  end

  def then_i_should_be_on_the_view_application_page
    expect(page).to have_content @application_awaiting_references.candidate.email_address
  end

  def when_i_click_on_chase_reference
    first(:link, t('application_form.referees.chase')).click
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content(t('application_form.referees.confirm_chase'))
  end

  def when_i_click_to_confirm_sending_the_chase_email
    click_button t('application_form.referees.chase_button')
  end

  def then_i_see_the_referee_email_is_successfully_sent
    candidate_name = "#{@application_awaiting_references.first_name} #{@application_awaiting_references.last_name}"
    open_email(@application_awaiting_references.references.first.email_address)

    expect(current_email.subject).to have_content(t('reference_request.subject.chaser', candidate_name: candidate_name))
  end

  def and_i_see_the_candidate_email_is_successfully_sent
    open_email(@application_awaiting_references.candidate.email_address)

    expect(current_email.subject).to have_content(t('candidate_reference.subject.chaser', referee_name: @application_awaiting_references.references.first.name))
  end

  def and_i_am_sent_back_to_the_application_form_with_a_flash
    expect(page).to have_content(t('application_form.referees.chase_success'))
  end
end
