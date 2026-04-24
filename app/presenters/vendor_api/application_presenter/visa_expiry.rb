module VendorAPI::ApplicationPresenter::VisaExpiry
  def schema
    super.deep_merge!({
      attributes: {
        visa_expired_at: application_form.visa_expired_at,
        visa_explanation: application_choice.visa_explanation,
        visa_explanation_details: application_choice.visa_explanation_details,
      },
    })
  end
end
