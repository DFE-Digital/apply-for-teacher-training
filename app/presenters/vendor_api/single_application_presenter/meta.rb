module VendorAPI::SingleApplicationPresenter::Meta
  def serialized_json
    references = VendorAPI::ApplicationPresenter.new(
      active_version,
      application,
      include_incomplete_references:,
    ).serialized_json

    meta = VendorAPI::MetaPresenter.new(active_version).as_json

    %({"data":#{references}, "meta": #{meta}})
  end
end
