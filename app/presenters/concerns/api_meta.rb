module APIMeta
  def serialized_json
    %({"data":#{VendorAPI::ApplicationPresenter.new(active_version, application).serialized_json}, "meta": #{VendorAPI::MetaPresenter.new(active_version).as_json}})
  end
end
