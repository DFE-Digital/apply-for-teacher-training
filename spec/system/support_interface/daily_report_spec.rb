require 'rails_helper'

RSpec.feature 'Daily Report' do
  scenario 'Every workday morning' do
    create(:application_choice, status: 'unsubmitted', updated_at: Time.zone.now + 1.day)
    create(:application_choice, status: 'awaiting_provider_decision')
    create(:application_choice, status: 'recruited')
    create(:application_choice, status: 'withdrawn')

    DailyReport.perform_async

    expect(WebMock).to have_requested(:post, 'https://example.com/slack-webhook').with { |req|
      payload = JSON.parse(req.body)

      expect(payload['channel']).to eql('#twd_apply_test')
      expect(payload['text']).to eql(":wave: Good morning! This is your daily stats update. Headlines: we've now got 4 sign-ups, 3 candidates who submitted their application, and 1 candidates who received and accepted an offer :tada:")
    }
  end
end
