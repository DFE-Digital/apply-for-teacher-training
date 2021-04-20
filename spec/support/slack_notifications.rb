RSpec.configure do |config|
  config.before do
    stub_request(:post, 'https://example.com/slack-webhook')
      .to_return(status: 200, body: '{}')
  end

  def expect_slack_message_with_text(expected_message)
    expect(WebMock).to have_requested(:post, 'https://example.com/slack-webhook').with { |req|
      sent_message = JSON.parse(req.body).fetch('text')
      sent_message.include?(expected_message)
    }
  end

  def expect_no_slack_message
    expect(WebMock).not_to have_requested(:post, 'https://example.com/slack-webhook')
  end
end
