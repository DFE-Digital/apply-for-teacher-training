module Azure
  include ActiveSupport::Configurable

  AzureTokenFilePathError = Class.new(StandardError)
  AzureAPIError = Class.new(StandardError)
end
