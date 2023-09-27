require 'rails_helper'

RSpec.describe 'InterviewPresenter' do
  subject(:interview_json) { interview_presenter.new(version, interview).as_json }

  let(:interview_presenter) { VendorAPI::InterviewPresenter }
  let(:version) { '1.1' }

  let(:expected_json) do
    {
      id: interview.id.to_s,
      provider_code: Provider.find(interview.provider_id).code,
      date_and_time: interview.date_and_time.iso8601,
      location: interview.location,
      additional_details: interview.additional_details,
      cancelled_at: interview.cancelled_at&.iso8601,
      cancellation_reason: interview.cancellation_reason,
      created_at: interview.created_at.iso8601,
      updated_at: interview.updated_at.iso8601,
    }.to_json
  end

  describe 'active interview' do
    let(:interview) { create(:interview, :future_date_and_time) }

    it 'includes all advertised fields' do
      expect(interview_json).to eq(expected_json)
    end
  end

  describe 'cancelled interview' do
    let(:interview) { create(:interview, :cancelled) }

    it 'includes all advertised fields' do
      expect(interview_json).to eq(expected_json)
    end
  end
end
