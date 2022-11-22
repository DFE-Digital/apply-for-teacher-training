module VendorAPI
  module Changes
    module WorkHistory
      class MarkDescriptionAsOptional < VersionChange
        description 'Mark `description` boolean as optional'

        resource ApplicationPresenter
      end
    end
  end
end
