module APIMeta
  def serialized_json
    %({"data":#{VendorAPI::ApplicationPresenter.new(active_version, application).serialized_json}, "meta": #{meta.to_json}})
  end

  def meta
    {
      version: "v#{active_version}",
      timestamp: Time.zone.now.iso8601,
    }
  end
end
