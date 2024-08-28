module EFLHelper
  def when_i_declare_a_non_english_nationality
    current_candidate.current_application.update(
      first_nationality: 'Hong Konger',
      second_nationality: 'Pakistani',
    )
    visit candidate_interface_details_path
  end

  def when_i_click_on_the_efl_section_link
    click_link_or_button efl_link_text
  end

  def and_i_declare_a_non_english_speaking_nationality
    when_i_declare_a_non_english_nationality
  end

  def and_i_click_on_the_efl_section_link
    when_i_click_on_the_efl_section_link
  end

  def efl_link_text
    'English as a foreign language'
  end
end
