require 'rails_helper'

RSpec.describe DeclineReferenceRequest do
  it 'sets the rejected_reference_request status' do
    application = create(:completed_application_form)
    referee = create(:reference, application_form: application)
    described_class.new(referee: referee).save!

    expect(referee.rejected_reference_request).to be_truthy
  end
end
