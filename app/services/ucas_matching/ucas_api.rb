module UCASMatching
  class UCASAPI
    def self.auth_string
      "Bearer #{access_token}"
    end

    def self.access_token
      # https://transfer.ucasenvironments.com/swagger/ui/index#/Authentication/Auth_GetToken
      response = HTTP
        .post(
          "#{base_url}/token",
          form: {
            grant_type: 'password',
            username: ENV.fetch('UCAS_USERNAME'),
            password: ENV.fetch('UCAS_PASSWORD'),
          },
        )

      if response.status.success?
        JSON.parse(response.body).fetch('access_token')
      else
        raise UCASMatching::APIError, "HTTP #{response.status} when fetching access token: '#{response}'"
      end
    end

    def self.base_url
      ENV.fetch('UCAS_UPLOAD_BASEURL')
    end

    def self.upload_folder
      ENV.fetch('UCAS_UPLOAD_FOLDER')
    end

    def self.download_folder
      HostingEnvironment.production? ? 696965300 : 691078359
    end
  end
end
