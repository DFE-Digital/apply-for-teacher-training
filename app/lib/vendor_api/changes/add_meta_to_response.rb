module VendorAPI
  module Changes
    class AddMetaToResponse < VersionChange
      description 'Includes top level meta object'

      resource MetaPresenter
      resource SingleApplicationPresenter, [SingleApplicationPresenter::Meta]
    end
  end
end
