require 'rails_helper'

# I used this file to test various components with the choice in interviewing without interviews

RSpec.describe 'Interviewing without interviews spike' do
  let(:application_form) { create(:application_form, :submitted) }
  let(:choice) { create(:application_choice, :interviewing_without_interviews, application_form:) }

  it 'does not blow up components' do
    expect {
      CandidateInterface::CourseChoicesReviewComponent.new(application_form:)
    }.not_to raise_error

    expect {
      CandidateInterface::InterviewBookingsComponent.new(application_choice: choice)
    }.not_to raise_error

    expect {
      InterviewPreferencesComponent.new(application_form:)
    }.not_to raise_error

    expect {
      SupportInterface::ApplicationChoiceComponent.new(application_choice: choice)
    }.not_to raise_error

    expect {
      SupportInterface::ApplicationSummaryComponent.new(application_form:)
    }.not_to raise_error
  end
end
