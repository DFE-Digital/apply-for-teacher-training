module VendorAPI::ReferencePresenter::FeedbackProvidedAt
  def schema
    super.deep_merge!({
      feedback_provided_at: (reference.feedback_provided_at&.iso8601 if reference_received?),
    })
  end
end
