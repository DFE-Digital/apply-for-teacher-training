module VendorAPI
  module Changes
    class ApplicationMeta < VersionChange
      description 'Includes top level meta object'

      resource MetaPresenter
      resource SingleApplicationPresenter, [APIMeta]
    end
  end
end
