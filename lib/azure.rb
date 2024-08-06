module Azure
  include ActiveSupport::Configurable

  AzureError = Class.new(StandardError) do
    def initialize(status:, body:)
      @status = status
      @body = body
    end

    def message
      "\r\n\tstatus:\t#{@status}\r\n\tbody:\t#{@body}"
    end
  end
  AzureAPIError = Class.new(AzureError)
  GoogleAPIError = Class.new(AzureError)
  STSAPIError = Class.new(AzureError)

  AzureTokenFilePathError = Class.new(StandardError) do
    def message
      'Azure token file could not be found'
    end
  end
end
