module VendorAPI::ApplicationPresenter::HesaData
  def schema
    super.deep_merge!({
      attributes: {
        hesa_data: hesa_data,
      },
    })
  end

  def hesa_data
    return nil unless ApplicationStateChange::ACCEPTED_STATES.include?(application_choice.status.to_sym)

    equality_and_diversity_data = application_form&.equality_and_diversity

    if equality_and_diversity_data
      {
        sex: equality_and_diversity_data['hesa_sex'],
        disability: equality_and_diversity_data['hesa_disabilities'],
        ethnicity: equality_and_diversity_data['hesa_ethnicity'],
      }.merge(additional_hesa_itt_data(equality_and_diversity_data))
    end
  end
end
