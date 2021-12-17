module VendorAPI
  module Changes
    class ConfirmConditionsMet < VersionChange
      description \
        "Confirm offer conditions\n" \
        "Confirm that the candidate has met all the conditions set out in the offer\n" \
        'This will transition the application to the recruited state.'

      action DecisionsController, :confirm_conditions_met
    end
  end
end
