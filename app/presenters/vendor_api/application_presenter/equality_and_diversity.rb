module VendorAPI::ApplicationPresenter::EqualityAndDiversity
  def schema
    super.deep_merge!({
      attributes: {
        equality_and_diversity: equality_and_diversity,
      },
    })
  end

  def equality_and_diversity
    return nil unless application_choice.state_offer_accepted? &&
                      application_choice.application_form.recruitment_cycle_year == RecruitmentCycleTimetable.current_year

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
