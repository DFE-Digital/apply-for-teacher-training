module VendorAPI
  module Changes
    class MarkPhaseAsDeprecated < VersionChange
      description 'Mark application `phase` as deprecated'

      resource ApplicationPresenter
    end
  end
end
