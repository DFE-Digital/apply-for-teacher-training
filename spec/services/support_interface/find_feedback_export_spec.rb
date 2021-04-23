require 'rails_helper'

RSpec.describe SupportInterface::FindFeedbackExport do
  describe 'documentation' do
    before { create(:find_feedback) }

    it_behaves_like 'a data export'
  end

  describe '#data_for_export' do
    it 'returns an array of hashes containing feedback from Find' do
      feedback1 = create(:find_feedback)
      feedback2 = create(:find_feedback, find_controller: 'courses', path: '/course/L24/2CCR', created_at: 1.day.ago)

      expect(described_class.new.data_for_export).to contain_exactly(
        {
          feedback_provided_at: feedback2.created_at,
          find_url: 'https://www.find-postgraduate-teacher-training.service.gov.uk/course/L24/2CCR',
          email: feedback2.email_address,
          feedback: feedback2.feedback,
        },
        {
          feedback_provided_at: feedback1.created_at,
          find_url: 'https://www.find-postgraduate-teacher-training.service.gov.uk/results',
          email: feedback1.email_address,
          feedback: feedback1.feedback,
        },
      )
    end
  end
end
