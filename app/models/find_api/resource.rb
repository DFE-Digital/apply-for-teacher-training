module FindAPI
  class Resource < JsonApiClient::Resource
    self.site = ENV.fetch('FIND_BASE_URL')
  end
end
