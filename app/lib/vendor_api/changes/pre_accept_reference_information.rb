module VendorAPI
  module Changes
    class PreAcceptReferenceInformation < VersionChange
      description 'Viewing references before an offer has been accepted will show referee details but `null` values for `reference` and `safeguarding_concerns`.'

      resource ApplicationPresenter
    end
  end
end
