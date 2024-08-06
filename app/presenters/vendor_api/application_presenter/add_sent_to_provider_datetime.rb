module VendorAPI::ApplicationPresenter::AddSentToProviderDatetime
  def schema
    super.deep_merge!({
      attributes: {
        sent_to_provider_at: application_choice.sent_to_provider_at&.iso8601,
      },
    })
  end
end
