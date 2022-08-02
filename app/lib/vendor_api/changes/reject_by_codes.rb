module VendorAPI
  module Changes
    class RejectByCodes < VersionChange
      description 'Reject application with reasons codes via the API.'

      action DecisionsController, :reject_by_codes
    end
  end
end
