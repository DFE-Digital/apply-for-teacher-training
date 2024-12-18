require 'rails_helper'

RSpec.describe 'Candidate selects level-two withdrawal reasons' do
  include CandidateHelper
  include WithdrawalReasonsTestHelpers

  before do
    FeatureFlag.activate(:new_candidate_withdrawal_reasons)
    @candidate = create(:candidate)
    @application_form = create(:completed_application_form, submitted_at: Time.zone.now, candidate: @candidate)
  end

  shared_examples_for 'Candidate selects a level-one reason and views level-two reasons' do |level_one_reason|
    scenario 'Candidate can navigate around the page after selecting', time: mid_cycle do
      given_i_have_submitted_an_application
      and_i_am_signed_in
      when_i_view_the_application
      and_i_click_on('withdraw this application')
      when_i_select_the_level_one_reason(level_one_reason)
      then_i_see_the_correct_level_two_options_page(level_one_reason)

      when_i_click_on('Back')
      then_i_am_on_the_start_page
      and_the_level_one_reason_is_selected(level_one_reason)

      when_i_click_on('Continue')
      and_i_select_the_main_other_option
      when_i_enter_details_for_main_other_option
      and_i_click_on('Continue')
      then_i_am_on_the_review_page

      when_i_click_on('Change main reason for withdrawal')
      then_i_am_on_the_edit_page
      and_the_level_one_reason_is_selected(level_one_reason)

      when_i_click_on('Continue')
      and_other_is_selected
      when_i_click_on('Continue')
      then_i_am_on_the_review_page

      when_i_click_on('Change additional details for withdrawal')
      then_i_see_the_correct_level_two_options_page(level_one_reason)
      and_other_is_selected

      when_i_click_on('Continue')
      then_i_am_on_the_review_page
      and_i_click_on('Cancel')
      then_i_am_on_the_applications_choice_page
    end
  end

  it_behaves_like(
    'Candidate selects a level-one reason and views level-two reasons',
    'I am going to apply (or have applied) to a different training provider',
  )

  it_behaves_like(
    'Candidate selects a level-one reason and views level-two reasons',
    'I am going to change or update my application with this training provider',
  )

  it_behaves_like(
    'Candidate selects a level-one reason and views level-two reasons',
    'I plan to apply for teacher training in the future',
  )

  it_behaves_like(
    'Candidate selects a level-one reason and views level-two reasons',
    'I do not want to train to teach anymore',
  )
  def then_i_am_on_the_start_page
    expect(page).to have_current_path(
      candidate_interface_withdrawal_reasons_level_one_reason_new_path(id: @application_choice.id),
      ignore_query: true,
    )
  end

  def then_i_am_on_the_edit_page
    expect(page).to have_content 'Why are you withdrawing this application?'
  end

  def and_other_is_selected
    other_field = find('input[type="checkbox"][value="other"]')
    expect(other_field.checked?).to be true
  end

  def then_i_am_on_the_applications_choice_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def and_the_level_one_reason_is_selected(level_one_reason)
    expect(find_field(level_one_reason).checked?).to be true
  end

  def then_i_see_the_correct_level_two_options_page(level_one_reason)
    key = reason_key_mapping[level_one_reason]
    expect(page).to have_current_path(
      candidate_interface_withdrawal_reasons_level_two_reasons_new_path(id: @application_choice.id, level_one_reason: key),
    )
    case key
    when 'applying-to-another-provider'
      [
        'I have accepted another offer',
        'I have seen a course that suits me better',
        'The training provider has not replied to me',
        'The location I’m expected to train at is too far away',
        'My personal circumstances have changed',
        'The course is not available anymore',
        'Other',
      ].each do |supporting_reason|
        expect(page).to have_content(supporting_reason)
      end
      expect(page).to have_title 'Why are you applying to another training provider?'
      expect(page).to have_content 'Why are you applying to another training provider?'
    when 'change-or-update-application-with-this-provider'
      [
        'I want to update my application, for example correct an error or add information',
        'I want to change my study pattern, for example from full time to part time',
        'I want to apply for a different subject with the same provider',
        'Other',
      ].each do |supporting_reason|
        expect(page).to have_content(supporting_reason)
      end
      expect(page).to have_title 'Why are you changing or updating your application with this training provider?'
      expect(page).to have_content 'Why are you changing or updating your application with this training provider?'
    when 'apply-in-the-future'
      [
        'My personal circumstances have changed',
        'I want to get more experience before I apply again',
        'I want to improve my qualifications before I apply again',
        'Other',
      ].each do |supporting_reason|
        expect(page).to have_content(supporting_reason)
      end
      expect(page).to have_title 'Why are you planning to apply for teacher training in the future?'
      expect(page).to have_content 'Why are you planning to apply for teacher training in the future?'
    when 'do-not-want-to-train-anymore'

      [
        'My personal circumstances have changed',
        'I have decided on another career path or I have accepted a job offer',
        'Other',
      ].each do |supporting_reason|
        expect(page).to have_content(supporting_reason)
      end
      expect(page).to have_title 'Why do you not want to train to teach anymore?'
      expect(page).to have_content 'Why do you not want to train to teach anymore?'
    end
  end
end
