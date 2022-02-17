module VendorAPI
  module Changes
    class AddMetaToApplication < VersionChange
      description 'Adds top level meta object to single application response'

      resource MetaPresenter
      resource SingleApplicationPresenter, [SingleApplicationPresenter::Meta]
    end
  end
end
