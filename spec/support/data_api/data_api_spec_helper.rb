module DataAPISpecHelper
  def get_api_request(url, token:, options: {})
    headers_and_params = {
      headers: {
        'Authorization' => "Bearer #{token}",
      },
    }.deep_merge(options)

    get url, **headers_and_params
  end

  def tad_api_token
    @tad_api_token ||= DataAPIUser.tad_user.create_magic_link_token!
  end
end
