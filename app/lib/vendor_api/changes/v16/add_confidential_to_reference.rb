module VendorAPI
  module Changes
    module V16
      class AddConfidentialToReference < VersionChange
        description 'Add the confidentiality status selected by the referee for the reference.'

        resource ReferencePresenter, [ReferencePresenter::AddConfidential]
      end
    end
  end
end
