require 'rails_helper'

RSpec.feature 'Candidates awaiting references application choices are rejected when the new cycle launches' do
  include CandidateHelper

  scenario 'An application is rejected when find opens for a new cycle' do
    given_i_have_submitted_my_application

    when_the_apply_2_deadline_has_passed
    then_the_candidates_application_choices_should_be_rejected
  end

  def given_i_have_submitted_my_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def when_the_apply_2_deadline_has_passed
    Timecop.travel(EndOfCycleTimetable.apply_2_deadline + 1.day) do
      RejectAwaitingReferencesCourseChoicesWorker.perform
    end
  end

  def then_the_candidates_application_choices_should_be_rejected
    expect(@application.application_choices.reload.first.status).to eq 'rejected_at_end_of_cycle'
    expect(@application.application_choices.reload.first.rejection_reason).to eq 'Awaiting references when the recruitment cycle closed.'
  end
end
