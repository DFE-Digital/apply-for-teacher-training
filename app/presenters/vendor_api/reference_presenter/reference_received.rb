module VendorAPI::ReferencePresenter::ReferenceReceived
  def schema
    super.deep_merge!({
      reference_received: reference_received?,
    })
  end
end
