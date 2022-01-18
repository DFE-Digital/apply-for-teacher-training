module OfferDetails
  def schema
    super.deep_merge!(attributes: {
      offer: {
        course: {
          course_code: application_choice.offer.course.code,
          provider_code: application_choice.offer.course.provider.code,
        },
        offer_declined_at: application_choice.declined_at,
        offer_accepted_at: application_choice.accepted_at,
        offer_made_at: application_choice.offered_at,
        conditions: application_choice.offer.conditions.map(&:text),
      },
    })
  end
end
