module VendorAPI
  module Changes
    class RejectionReasonCodes < VersionChange
      description 'An array of objects denoting possible rejection reason codes, their corresponding rejection category and default details text.'

      action ReferenceDataController, :rejection_reason_codes
    end
  end
end
