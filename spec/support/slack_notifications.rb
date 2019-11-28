RSpec.configure do |config|
  config.before do
    stub_request(:post, 'https://example.com/slack-webhook').
      to_return(status: 200, body: '{}')
  end

  def expect_slack_message_with_text(text)
    expect(WebMock).to have_requested(:post, 'https://example.com/slack-webhook').with { |req|
      JSON.parse(req.body)['text'].match(text)
    }
  end
end
