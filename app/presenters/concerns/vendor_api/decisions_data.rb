module VendorAPI
  module DecisionsData
    include CourseData
    include FieldTruncation

    def withdrawal
      return unless application_choice.withdrawn?

      {
        reason: nil, # Candidates are not able to provide a withdrawal reason yet
        date: application_choice.withdrawn_at.iso8601,
      }
    end

    def rejection
      @rejection ||= if application_choice.rejection_reason? || application_choice.structured_rejection_reasons.present?
                       {
                         reason: VendorAPI::RejectionReasonPresenter.new(application_choice).present,
                         date: application_choice.rejected_at.iso8601,
                       }
                     elsif application_choice.offer_withdrawal_reason?
                       {
                         reason: application_choice.offer_withdrawal_reason,
                         date: application_choice.offer_withdrawn_at.iso8601,
                       }
                     elsif application_choice.rejected_by_default?
                       {
                         reason: 'Not entered',
                         date: application_choice.rejected_at.iso8601,
                       }
                     end
      return if @rejection.blank?

      {
        reason: truncate_if_over_advertised_limit('Rejection.properties.reason', @rejection[:reason]),
        date: @rejection[:date],
      }
    end

    def offer
      return nil if application_choice.offer.nil?

      {
        conditions: application_choice.offer.conditions_text,
        offer_made_at: application_choice.offered_at,
        offer_accepted_at: application_choice.accepted_at,
        offer_declined_at: application_choice.declined_at,
      }.merge(current_course)
    end
  end
end
