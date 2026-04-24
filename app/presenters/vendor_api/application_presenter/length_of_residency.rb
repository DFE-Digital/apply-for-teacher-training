module VendorAPI::ApplicationPresenter::LengthOfResidency
  def schema
    super.deep_merge!({
      attributes: {
        country_residency_date_from: application_form.country_residency_date_from,
        country_residency_since_birth: application_form.country_residency_since_birth,
      },
    })
  end
end
