class ProviderInterface::Tracking
  attr_reader :current_user, :request

  def initialize(current_user, request)
    @current_user = current_user
    @request = request
  end

  def provider_download_application
    event = DfE::Analytics::Event.new
      .with_type(:provider_download_application)
      .with_user(current_user)
      .with_request_details(request)

    DfE::Analytics::SendEvents.do([event])
  end

  def provider_download_references
    event = DfE::Analytics::Event.new
      .with_type(:provider_download_references)
      .with_user(current_user)
      .with_request_details(request)

    DfE::Analytics::SendEvents.do([event])
  end
end
