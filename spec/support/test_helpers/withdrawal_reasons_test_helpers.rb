module WithdrawalReasonsTestHelpers
  def and_i_click_on(*args)
    Array(args).each do |text|
      click_on text
    end
  end
  alias when_i_click_on and_i_click_on

  def and_i_check(*args)
    Array(args).each do |text|
      check text
    end
  end

  def given_i_have_submitted_an_application
    @application_choice = create(
      :application_choice,
      status: 'awaiting_provider_decision',
      application_form: @application_form,
    )
  end

  def when_i_view_the_application
    click_on 'Your applications'
    click_on @application_choice.current_course_option.provider.name
  end

  def and_i_am_signed_in
    login_as(@candidate)
    visit root_path
  end

  def then_i_see_the_success_message
    expect(page).to have_content "You have withdrawn your application to #{@application_choice.current_course_option.provider.name}"
  end

  def then_i_am_on_the_review_page
    expect(page).to have_content 'Are you sure you want to withdraw this application?'
  end

  def when_i_select_the_level_one_reason(level_one_reason)
    choose level_one_reason
    click_on 'Continue'
  end
  alias and_i_select_the_level_one_reason when_i_select_the_level_one_reason

  def then_i_see_the_error_message(error_message)
    expect(page).to have_content('There is a problem')
    expect(page).to have_content(error_message).twice
  end

  def when_i_enter_details_for_main_other_option(error: false)
    id = 'candidate-interface-withdrawal-reasons-level-two-reasons-form-comment-field'
    id += '-error' if error
    other_details_field = find_by_id(id)
    other_details_field.set('Here is some more detail that does not quite match the options above.')
  end
  alias enter_details_for_main_other_option when_i_enter_details_for_main_other_option
  alias and_i_enter_details_for_main_other_option when_i_enter_details_for_main_other_option

  def and_i_select_the_main_other_option
    find('input[type="checkbox"][value="other"]').check
  end
  alias select_the_main_other_option and_i_select_the_main_other_option
  alias when_i_select_the_main_other_option and_i_select_the_main_other_option

  def and_i_select_the_personal_circumstances_other_option
    find('input[type="checkbox"][value="personal-circumstances-have-changed.other"]').check
  end
  alias select_the_personal_circumstances_other_option and_i_select_the_personal_circumstances_other_option
  alias when_i_select_the_personal_circumstances_other_option and_i_select_the_personal_circumstances_other_option

  def level_one_reasons
    [
      'I am going to apply (or have applied) to a different training provider',
      'I am going to change or update my application with this training provider',
      'I plan to apply for teacher training in the future',
      'I do not want to train to teach anymore',
      'Other',
    ]
  end

  def reason_key_mapping
    {
      'I am going to apply (or have applied) to a different training provider' => 'applying-to-another-provider',
      'I am going to change or update my application with this training provider' => 'change-or-update-application-with-this-provider',
      'I plan to apply for teacher training in the future' => 'apply-in-the-future',
      'I do not want to train to teach anymore' => 'do-not-want-to-train-anymore',
    }
  end

  def then_i_have_withdrawn_from_the_course(course = @application_choice)
    expect(page).to have_content "You have withdrawn your application to #{course.current_course.provider.name}"
    expect(course.reload.status).to eq 'withdrawn'
  end

  def when_i_select_some_reasons_and_confirm
    choose 'I do not want to train to teach anymore'
    click_on 'Continue'
    check 'I have decided on another career path or I have accepted a job offer'
    click_on 'Continue'
    click_on 'Yes I’m sure – withdraw this application'
  end
  alias and_i_select_some_reasons_and_confirm when_i_select_some_reasons_and_confirm
end
