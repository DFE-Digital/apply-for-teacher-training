require 'rails_helper'

RSpec.describe DeclineOfferByDefault do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, status: :offer) }

  it 'updates the application_choice' do
    described_class.new(application_form: application_choice.application_form).call

    application_choice.reload

    expect(application_choice.declined_by_default).to be(true)
    expect(application_choice.declined_at).not_to be_nil
    expect(application_choice.withdrawn_or_declined_for_candidate_by_provider).to be false
  end
end
