require 'rails_helper'

RSpec.describe SendApplicationsToProvider do
  it 'sends the form’s choices to the provider' do
    form = create(:completed_application_form, :with_completed_references, :ready_to_send_to_provider)
    create(:application_choice, application_form: form, status: :application_complete)
    create(:application_choice, application_form: form, status: :application_complete)

    SendApplicationsToProvider.new.call

    expect(form.application_choices.map(&:status)).to eq %w[awaiting_provider_decision awaiting_provider_decision]
  end

  it 'sends application_complete choices to the provider if the other choices are cancelled' do
    form = create(:completed_application_form, :with_completed_references, :ready_to_send_to_provider)
    create(:application_choice, application_form: form, status: :application_complete)
    create(:application_choice, application_form: form, status: :cancelled)

    SendApplicationsToProvider.new.call

    expect(form.application_choices.map(&:status)).to match_array %w[awaiting_provider_decision cancelled]
  end
end
