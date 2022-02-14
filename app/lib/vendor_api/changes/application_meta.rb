module VendorAPI
  module Changes
    class ApplicationMeta < VersionChange
      description 'Includes top level meta object'

      resource MetaPresenter
      resource SingleApplicationPresenter, [VendorAPI::MetaPresenter::APIMeta]
    end
  end
end
