module WorkloadIdentityFederation
  include ActiveSupport::Configurable

  WorkloadIdentityFederationError = Class.new(StandardError) do
    def initialize(status:, body:)
      @status = status
      @body = body
    end

    def message
      "\r\n\tstatus:\t#{@status}\r\n\tbody:\t#{@body}"
    end
  end
  AzureAPIError = Class.new(WorkloadIdentityFederationError)
  GoogleAPIError = Class.new(WorkloadIdentityFederationError)
  STSAPIError = Class.new(WorkloadIdentityFederationError)
  GoogleCloudCredentialsError = Class.new(StandardError) do
    def message
      'Google Cloud Credentials could not be parsed'
    end
  end

  AzureTokenFilePathError = Class.new(StandardError) do
    def message
      'Azure token file could not be found'
    end
  end
end
