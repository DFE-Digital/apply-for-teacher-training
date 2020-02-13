require 'rails_helper'

RSpec.feature 'Receives rejection email' do
  include CandidateHelper

  scenario 'Receives rejection email' do
    given_the_pilot_is_open
    and_candidate_rejected_by_provider_email_is_active
    and_all_but_one_of_my_application_choices_have_been_rejected

    when_a_provider_rejects_my_last_application
    then_i_receive_the_all_applications_rejected_email
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_candidate_rejected_by_provider_email_is_active
    FeatureFlag.activate('candidate_rejected_by_provider_email')
  end

  def and_all_but_one_of_my_application_choices_have_been_rejected
    @application_form = create(:completed_application_form)
    create_list(:application_choice, 2, status: :rejected, application_form: @application_form)
    @application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: @application_form)
  end

  def when_a_provider_rejects_my_last_application
    RejectApplication.new(application_choice: @application_choice, rejection_reason: 'No experience working with children.').save
  end

  def then_i_receive_the_all_applications_rejected_email
    open_email(@application_form.candidate.email_address)

    expect(current_email.subject).to include(t('application_choice_rejected_email.subject', provider_name: @application_choice.provider.name))
  end
end
