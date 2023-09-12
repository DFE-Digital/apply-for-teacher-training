require 'rails_helper'

RSpec.feature 'Candidate submits the application', :continuous_applications do
  include CandidateHelper

  it 'Candidate with a completed application' do
    given_i_am_signed_in

    when_i_have_completed_my_application
    and_i_review_my_application
    and_i_submit_the_application

    then_i_should_see_an_error_message_that_i_should_choose_an_option

    when_i_choose_no
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted

    and_i_review_my_application
    when_i_choose_to_submit
    and_i_click_continue

    then_i_can_see_my_application_has_been_successfully_submitted
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_submitted
    then_i_can_see_my_submitted_application
    and_i_can_see_i_have_three_choices_left
    # and_i_receive_an_email_confirmation

    when_i_have_three_further_draft_choices
    then_i_can_no_longer_add_more_course_choices

    when_i_submit_one_of_my_draft_applications
    then_i_still_cannot_add_course_choices

    when_one_of_my_applications_becomes_inactive
    then_i_am_able_to_add_another_choice
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_have_completed_my_application
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(
      :site,
      name: 'Main site',
      code: '-',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    @course = create(:course, :open_on_apply, name: 'Primary', code: '2XT2', provider: @provider)
    @course_option = create(:course_option, site:, course: @course)
    current_candidate.application_forms.delete_all
    current_candidate.application_forms << build(:application_form, :completed)
    @application_choice = create(:application_choice, :unsubmitted, course_option: @course_option, application_form: current_candidate.current_application)
  end

  def and_i_review_my_application
    visit candidate_interface_continuous_applications_choices_path
    click_on 'View application', match: :first
  end

  def and_i_submit_the_application
    and_i_click_continue
  end

  def and_i_click_continue
    click_button t('continue')
  end

  def when_i_choose_no
    choose 'No, save it as a draft'
  end

  def when_i_choose_to_submit
    choose 'Yes, submit it now'
  end

  def and_my_application_is_still_unsubmitted
    expect(@application_choice.reload).to be_unsubmitted
  end

  def and_i_can_see_my_course_choices
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
  end

  def then_i_should_see_an_error_message_that_i_should_choose_an_option
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content 'Select if you want to submit your application or save it as a draft'
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def and_i_am_redirected_to_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content 'Gorse SCITT'
  end

  def when_i_click_view_application
    within '.app-summary-card__actions' do
      click_link 'View application'
    end
  end

  def and_my_application_is_submitted
    expect(@application_choice.reload).to be_awaiting_provider_decision
  end

  def then_i_can_see_my_submitted_application
    expect(@current_candidate.current_application.application_choices).to contain_exactly(@application_choice)
    expect(page).to have_content 'Gorse SCITT'
    expect(page).to have_content 'Primary (2XT2)'
    expect(page).to have_content 'PGCE with QTS full time'
    expect(page).to have_content 'Awaiting decision'
  end

  def and_i_can_see_i_have_three_choices_left
    expect(page).to have_content 'You can add 3 more applications.'
  end

  def when_i_have_three_further_draft_choices
    @current_candidate.current_application.application_choices << build_list(:application_choice, 3, :unsubmitted)
  end

  def then_i_can_no_longer_add_more_course_choices
    visit current_path
    expect(page).to have_content 'You cannot add any more applications.'
    expect(page).to have_content 'If one of your applications is unsuccessful, or you withdraw or remove it, you will be able to add another application.'
  end
  alias_method :then_i_still_cannot_add_course_choices, :then_i_can_no_longer_add_more_course_choices

  def when_i_submit_one_of_my_draft_applications
    click_on 'Continue application', match: :first
    choose 'Yes, submit it now'
    click_button t('continue')
  end

  def when_one_of_my_applications_becomes_inactive
    @current_candidate.current_application.application_choices.where(status: 'awaiting_provider_decision').first.update!(status: 'inactive')
  end

  def then_i_am_able_to_add_another_choice
    visit current_path
    expect(page).to have_content 'You can add 1 more application.'
  end
end
