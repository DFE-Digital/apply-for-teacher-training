module VendorAPI
  module Changes
    class RejectApplication < VersionChange
      description \
        "Reject application\n" \
        "Reject the candidate’s application with a reason.\n" \
        'This will transition the application to the rejected state.'

      action DecisionsController, :reject
    end
  end
end
