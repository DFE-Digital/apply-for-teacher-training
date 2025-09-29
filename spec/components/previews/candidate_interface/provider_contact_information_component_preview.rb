class CandidateInterface::ProviderContactInformationComponentPreview < ViewComponent::Preview
  def default
    provider = Provider.new(email_address: 'email@gmail.com', phone_number: '0800 123 4567')

    render(CandidateInterface::ProviderContactInformationComponent.new(provider:))
  end
end
