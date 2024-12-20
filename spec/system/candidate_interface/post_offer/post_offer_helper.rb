module PostOfferHelper
  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_choices_path
  end

  def and_i_see_my_references
    expect(page).to have_content('References')
  end

  def and_i_see_my_offer_conditions
    expect(page).to have_content('Offer conditions')
    expect(page).to have_content("#{@application_choice.offer.conditions.first.text} Pending", normalize_ws: true)
  end

  def then_i_see_that_i_have_accepted_my_offer
    expect(page).to have_content("Your offer for #{@application_choice.current_course.name_and_code}")
    expect(page).to have_content("You have accepted an offer from #{@application_choice.course_option.course.provider.name} to study #{@application_choice.course.name_and_code}.")
  end

  def and_i_see_the_publisher_contact_information
    expect(page).to have_content("Contact #{@application_choice.current_provider.name} if you have any questions")
  end

  def and_i_see_a_link_to_view_the_application
    expect(page).to have_link('View application')
  end

  def and_i_see_a_link_to_withdraw_from_the_course
    expect(page).to have_link('Withdraw from the course')
  end
end
