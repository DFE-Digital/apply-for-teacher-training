require 'rails_helper'

RSpec.feature 'Referee is not required to submit a reference' do
  include CandidateHelper

  # Bullet complains about wanting an includes on a reference when it is cancelled as part of this spec.
  # We believe this is a false positive so will disable Bullet for this spec for now

  before do
    FeatureFlag.deactivate(:reference_selection)
    Bullet.raise = false
  end

  after do
    Bullet.raise = true
  end

  scenario 'Candidate has already received the minimum number of references' do
    given_the_candidate_has_requested_three_references_and_i_am_the_third_referee
    and_the_first_referee_has_responded_with_a_reference
    and_the_second_referee_has_responded_with_a_reference
    when_i_receive_an_email_with_a_reference_request
    and_i_click_on_the_link_within_the_email
    then_i_should_see_that_i_am_not_required_to_give_a_reference
  end

  def given_the_candidate_has_requested_three_references_and_i_am_the_third_referee
    @first_reference = create(:reference, :feedback_requested, email_address: 'terri@example.com', name: 'Terri Tudor')
    @second_reference = create(:reference, :feedback_requested, email_address: 'Bruce@Wayne.com', name: 'Bat Man')
    @third_reference = create(:reference, :feedback_requested, email_address: 'Clark@Kent.com', name: 'Super Man')
    @application = create(:completed_application_form,
                          application_references: [
                            @first_reference,
                            @second_reference,
                            @third_reference,
                          ],
                          candidate: current_candidate)
  end

  def and_the_first_referee_has_responded_with_a_reference
    submit_reference(@first_reference)
  end

  def and_the_second_referee_has_responded_with_a_reference
    submit_reference(@second_reference)
  end

  def submit_reference(reference)
    reference.update!(
      feedback: 'Lovable',
      relationship_correction: '',
      safeguarding_concerns: '',
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def when_i_receive_an_email_with_a_reference_request
    RefereeMailer.reference_request_email(@third_reference).deliver_now
    open_email('Clark@Kent.com')
  end

  def and_i_click_on_the_link_within_the_email
    click_sign_in_link(current_email)
  end

  def then_i_should_see_that_i_am_not_required_to_give_a_reference
    expect(page).to have_content('Thank you')
    expect(page).to have_content('You do not need to give a reference anymore')
  end
end
