require 'rails_helper'

RSpec.describe 'Candidate selects level-two withdrawal reasons' do
  include CandidateHelper
  include WithdrawalReasonsTestHelpers

  before do
    FeatureFlag.activate(:new_candidate_withdrawal_reasons)
    @candidate = create(:candidate)
    @application_form = create(:completed_application_form, submitted_at: Time.zone.now, candidate: @candidate)
  end

  scenario 'Candidate sees error messages unless all required data has been entered' do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on('withdraw this application')
    when_i_select_the_level_one_reason('I am going to apply (or have applied) to a different training provider')
    and_i_click_on('Continue')
    then_i_see_the_error_message('Select a reason for applying to another training provider')

    when_i_select_the_main_other_option
    and_i_click_on('Continue')
    then_i_see_the_error_message('Enter details to explain the reason for withdrawing')

    when_i_enter_details_for_main_other_option(error: true)
    and_i_check('My personal circumstances have changed')
    and_i_click_on('Continue')
    then_i_see_the_error_message('Select a reason why your personal circumstances have changed')

    when_i_select_the_personal_circumstances_other_option
    and_i_click_on('Continue')
    then_i_see_the_error_message('Enter details about the change to your personal circumstances')

    when_i_enter_details_for_personal_circumstances_other_option(error: true)
    and_i_click_on('Continue')
    then_i_am_on_the_review_page

    when_i_click_on('Yes I’m sure – withdraw this application')
    then_i_have_withdrawn_from_the_course
  end

  scenario 'Candidate selects all level-two reasons and withdraws' do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on('withdraw this application')
    when_i_select_the_level_one_reason('I am going to apply (or have applied) to a different training provider')
    and_i_select_all_the_level_two_reasons
    and_fill_in_required_details
    and_i_click_on('Continue')
    then_i_see_the_review_page

    when_i_click_on('Yes I’m sure – withdraw this application')
    then_i_have_withdrawn_from_the_course
    and_the_reasons_have_been_saved
  end

  def and_fill_in_required_details
    enter_details_for_personal_circumstances_other_option
    enter_details_for_main_other_option
  end

  def when_i_enter_details_for_personal_circumstances_other_option(error: false)
    id = 'candidate-interface-withdrawal-reasons-level-two-reasons-form-personal-circumstances-reasons-comment-field'
    id += '-error' if error
    personal_circumstances_other_field = find_by_id(id)
    personal_circumstances_other_field.set('Here are more details about my personal circumstances.')
  end
  alias_method :enter_details_for_personal_circumstances_other_option, :when_i_enter_details_for_personal_circumstances_other_option

  def and_i_select_all_the_level_two_reasons
    [
      'I have accepted another offer',
      'I have seen a course that suits me better',
      'The training provider has not replied to me',
      'The location I’m expected to train at is too far away',
      'My personal circumstances have changed',
      'I have concerns about the cost of doing the course',
      'I have concerns that I will not have time to train',
      'I have concerns about training with a disability or health condition',
      'The course is not available anymore',
    ].each do |reason|
      check reason
    end
    select_the_main_other_option
    select_the_personal_circumstances_other_option
  end

  def then_i_see_the_review_page
    expect(page).to have_content 'I am going to apply (or have applied) to a different training provider'
    [
      'I have accepted another offer',
      'I have seen a course that suits me better',
      'The training provider has not replied to me',
      'The location I’m expected to train at is too far away',
      'My personal circumstances have changed (Other): Here are more details about my personal circumstances.',
      'My personal circumstances have changed: I have concerns that I will not have time to train',
      'My personal circumstances have changed: I have concerns about training with a disability or health condition',
      'My personal circumstances have changed: I have concerns about the cost of doing the course',
      'The course is not available anymore',
      'Other: Here is some more detail that does not quite match the options above',
    ].each do |review_reason|
      expect(page).to have_content review_reason
    end
  end

  def then_i_have_withdrawn_from_the_course
    expect(page).to have_content "You have withdrawn your application to #{@application_choice.current_course.provider.name}"
    expect(@application_choice.reload.status).to eq 'withdrawn'
  end

  def and_the_reasons_have_been_saved
    expect(@application_choice.withdrawal_reasons.count).to eq 10
    expect(@application_choice.withdrawal_reasons.pluck(:reason)).to match(
      %w[
        applying-to-another-provider.accepted-another-offer
        applying-to-another-provider.seen-a-course-that-suits-me-better
        applying-to-another-provider.provider-has-not-replied-to-me
        applying-to-another-provider.location-is-too-far-away
        applying-to-another-provider.course-no-longer-available
        applying-to-another-provider.other
        applying-to-another-provider.personal-circumstances-have-changed.concerns-about-cost-of-doing-course
        applying-to-another-provider.personal-circumstances-have-changed.concerns-about-having-enough-time-to-train
        applying-to-another-provider.personal-circumstances-have-changed.concerns-about-training-with-a-disability-or-health-condition
        applying-to-another-provider.personal-circumstances-have-changed.other
      ],
    )
    expect(@application_choice.withdrawal_reasons.pluck(:status).uniq).to eq ['published']
  end
end
