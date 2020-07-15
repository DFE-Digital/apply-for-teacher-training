module EFLHelper
  def and_the_efl_feature_flag_is_active
    FeatureFlag.activate(:efl_section)
  end

  def and_i_declare_a_non_english_speaking_nationality
    visit candidate_interface_application_form_path
    click_link 'Personal details'
    candidate_fills_in_personal_details
    click_link 'Personal details'
    click_link 'Change nationality'
    select 'Hong Konger', from: 'Nationality'
    select 'Pakistani', from: 'Second nationality'
    click_button 'Save and continue'
    click_button 'Continue'
  end

  def and_i_click_on_the_efl_section_link
    click_link efl_link_text
  end

  def efl_link_text
    'English as a foreign language'
  end
end
