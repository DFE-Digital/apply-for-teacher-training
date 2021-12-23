module VendorAPI
  module Changes
    class ConfirmEnrolment < VersionChange
      description \
        "Confirm enrolment (DEPRECATED)\n" \
        "This endpoint has been deprecated and will return the application without changing it.\n" \
        'There is currently no meaning to `enrolment` in Apply for teacher training.'

      action DecisionsController, :confirm_enrolment
    end
  end
end
