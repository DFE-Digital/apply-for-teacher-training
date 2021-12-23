module VendorAPI
  module Changes
    class ConditionsNotMet < VersionChange
      description \
        " Conditions not met\n" \
        "The candidate has not met all the conditions set out in the offer.\n" \
        'This will transition the application to the conditions_not_met state.'

      action DecisionsController, :conditions_not_met
    end
  end
end
