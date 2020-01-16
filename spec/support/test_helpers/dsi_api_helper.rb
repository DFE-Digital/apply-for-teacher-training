module DsiAPIHelper
  def set_dsi_api_response(success:)
    if success
      stub_request(:post, "#{ENV.fetch('DSI_API_URL')}/services/apply/invitations").to_return(status: 202)
    else
      stub_request(:post, "#{ENV.fetch('DSI_API_URL')}/services/apply/invitations").to_return(
        status: 400,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: { errors: ['Missing given_name', 'Missing family_name'] }.to_json,
      )
    end
  end
end
