require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::DashboardComponent do
  let(:application_form) { create(:application_form) }

  subject(:result) do
    render_inline(described_class.new(application_form:))
  end

  before do
    create(:application_choice, :offer_withdrawn, application_form:)
    create(:application_choice, :withdrawn, application_form:)
    create(:application_choice, :declined, application_form:)
    create(:application_choice, :awaiting_provider_decision, application_form:)
    create(:application_choice, :inactive, application_form:)
    create(:application_choice, :interviewing, application_form:)
    create(:application_choice, :rejected, application_form:)
    create(:application_choice, :conditions_not_met, application_form:)
    create(:application_choice, :unsubmitted, application_form:)
    create(:application_choice, :application_not_sent, application_form:)
    create(:application_choice, :cancelled, application_form:)
    create(:application_choice, :offer, application_form:)
  end

  it 'sort group headers in the expected order' do
    expect(result.css('h2.grouped-application-header').map(&:text)).to eq([
      'Offers received',
      'Unsubmitted applications',
      'Unsuccessful applications',
      'In progress',
      'Declined offers',
      'Withdrawn applications',
    ])
  end
end
