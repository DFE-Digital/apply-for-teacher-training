module VendorAPI
  module Changes
    class AddMetaToResponse < VersionChange
      description 'Includes top level meta object'

      resource MetaPresenter
      resource SingleApplicationPresenter, [VendorAPI::ResponseMeta]
    end
  end
end
