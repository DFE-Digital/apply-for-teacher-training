require 'rails_helper'

RSpec.describe SendApplicationToProvider do
  def create_application
    application_form = create :application_form
    create(
      :application_choice,
      application_form: application_form,
      status: 'application_complete',
      edit_by: 2.business_days.ago,
    )
  end

  it 'sets the status to `awaiting_provider_decision`' do
    application_choice = create_application
    SendApplicationToProvider.new(application_choice: application_choice).call
    expect(application_choice.reload.status).to eq 'awaiting_provider_decision'
  end
end
