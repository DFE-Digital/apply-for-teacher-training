module VendorAPI
  module Changes
    class Add2023HesaToApplication < VersionChange
      description 'Include the 2023 HESA codes associated with the application'

      resource ApplicationPresenter, [ApplicationPresenter::EqualityAndDiversity]
    end
  end
end
