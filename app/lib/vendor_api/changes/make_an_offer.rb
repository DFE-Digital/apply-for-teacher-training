module VendorAPI
  module Changes
    class MakeAnOffer < VersionChange
      description \
        "Make an offer to the candidate.\n" \
        "This will transition the application to the offer state.\n" \
        'If the application has already received an offer, POSTing a second offer will change that offer.'

      action DecisionsController, :make_offer
    end
  end
end
