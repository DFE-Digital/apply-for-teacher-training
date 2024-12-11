module VendorAPI::ReferencePresenter::AddConfidential
  def schema
    super.deep_merge!({
      confidential: reference.confidential,
    })
  end
end
