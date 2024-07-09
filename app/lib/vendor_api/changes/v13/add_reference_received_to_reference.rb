module VendorAPI
  module Changes
    module V13
      class AddReferenceReceivedToReference < VersionChange
        description 'Include reference received in Reference json responses.'

        resource ReferencePresenter, [ReferencePresenter::ReferenceReceived]
      end
    end
  end
end
