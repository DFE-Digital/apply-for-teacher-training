require 'rails_helper'

RSpec.describe 'Candidates sees all their applications' do
  include CandidateHelper

  before do
    create_and_sign_in_candidate
    @application_form = create(:application_form, candidate: current_candidate)
  end

  scenario 'showing all tabs' do
    given_i_have_application_choices_in_all_states_possible_for_the_navigation
    when_i_visit_my_applications
    then_i_see_all_the_tabs
    when_i_visit_my_applications_passing_an_non_existent_tab_name
    then_i_see_all_the_tabs
    and_all_applications_tabs_are_selected
  end

  scenario 'showing some tabs depending of what kind of application choices states candidate has' do
    given_i_have_application_choices_in_some_states
    when_i_visit_my_applications
    then_i_only_see_the_tabs_related_to_the_application_choice_states_that_i_have
    when_i_click_in_the_drafts_tab
    then_i_only_see_the_draft_applications
    when_i_click_to_view_my_application
    then_i_am_on_the_view_my_application_page
    when_i_visit_my_applications
    and_i_click_to_view_the_offers_tab
    then_i_only_see_the_offers_applications
    when_i_click_to_view_my_application
    then_i_am_on_the_details_offer_page
    when_i_visit_my_applications
    and_i_click_to_view_the_unsuccessful_tab
    then_i_only_see_the_unsuccessful_applications
  end

  def given_i_have_application_choices_in_all_states_possible_for_the_navigation
    %w[offer unsubmitted rejected interviewing offer_withdrawn declined].each do |state|
      create(:application_choice, state, application_form: @application_form)
    end
  end

  def then_i_see_all_the_tabs
    I18n.t('candidate_interface.application_tabs').each_value do |tab|
      expect(tabs).to include(tab)
    end
  end

  def given_i_have_application_choices_in_some_states
    %w[offer unsubmitted rejected].each do |state|
      create(:application_choice, state, application_form: @application_form)
    end
  end

  def then_i_only_see_the_tabs_related_to_the_application_choice_states_that_i_have
    expect(tabs).to eq(['All applications', 'Offers received', 'Draft', 'Unsuccessful'])
  end

  def when_i_click_in_the_drafts_tab
    click_link_or_button 'Draft'
  end

  def then_i_only_see_the_draft_applications
    and_i_only_see_applications_in(state: :unsubmitted)
  end

  def then_i_am_on_the_view_my_application_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_course_review_path(@application_choice.id),
    )
  end

  def and_i_click_to_view_the_offers_tab
    click_link_or_button 'Offers received'
  end

  def then_i_only_see_the_offers_applications
    and_i_only_see_applications_in(state: :offer)
  end

  def then_i_am_on_the_details_offer_page
    expect(page).to have_current_path(
      candidate_interface_offer_path(@application_choice.id),
    )
  end

  def and_i_click_to_view_the_unsuccessful_tab
    click_link_or_button 'Unsuccessful'
  end

  def then_i_only_see_the_unsuccessful_applications
    and_i_only_see_applications_in(state: :rejected)
  end

  def when_i_visit_my_applications_passing_an_non_existent_tab_name
    visit candidate_interface_application_choices_path(current_tab_name: 'this-does-not-exist')
  end

  def and_all_applications_tabs_are_selected
    current_tab = tabs_links.find { |tab_link| tab_link['aria-current'].present? }

    expect(current_tab).to be_present
    expect(current_tab.text).to eq('All applications')
  end

private

  def and_i_only_see_applications_in(state:)
    expect(page.all('.app-application-item').size).to be 1

    @application_choice = @application_form.application_choices.send(state).first
    application_link = page.first('.app-application-item a')

    expect(application_link.text).to include(
      @application_choice.provider.name,
      @application_choice.current_course.name_and_code,
    )

    if state.to_sym == :offer
      expect(application_link[:href]).to eq(
        candidate_interface_offer_path(@application_choice.id),
      )
    else
      expect(application_link[:href]).to eq(
        candidate_interface_course_choices_course_review_path(@application_choice.id),
      )
    end
  end

  def tabs
    tabs_links.map(&:text)
  end

  def tabs_links
    page.all('.tabs-component a')
  end
end
