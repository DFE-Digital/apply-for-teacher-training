require 'rails_helper'

RSpec.feature 'Receives rejection email', :continuous_applications do
  include CandidateHelper

  scenario 'Receives rejection email' do
    when_i_have_submitted_an_application
    and_a_provider_rejects_my_application
    then_i_receive_the_application_rejected_email
    and_it_includes_details_of_my_application
  end

  def when_i_have_submitted_an_application
    @application_form = create(:completed_application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def and_a_provider_rejects_my_application
    RejectApplication.new(
      actor: create(:support_user),
      application_choice: @application_choice,
      rejection_reason: 'No experience working with children.',
    ).save
  end

  def then_i_receive_the_application_rejected_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(I18n.t!('candidate_mailer.application_rejected.subject'))
  end

  def and_it_includes_details_of_my_application
    expect(current_email.text).to include(@application_choice.course.provider.name)
    expect(current_email.text).to include(@application_choice.course.name)
    expect(current_email.text).to include('No experience working with children.')
  end
end
