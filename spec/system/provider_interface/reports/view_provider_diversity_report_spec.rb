require 'rails_helper'

RSpec.describe 'Provider views the diversity report' do
  include DfESignInHelpers

  scenario 'when provider user views the diversity report' do
    given_a_provider_and_provider_user_exists
    and_application_forms_exist_for_the_provider
    and_i_am_signed_in_as_provider_user
    when_i_visit_the_reports_index
    and_i_click_on_sex_disability_ethnicity_and_age_of_candidates
    then_i_see_the_sex_disability_ethnicity_and_age_report_for_the_providers_candidates
    and_i_see_the_sex_data_table
    and_i_see_the_disability_data_tables
    and_i_see_the_ethnicity_data_table
    and_i_see_the_age_data_table
  end

  def when_i_visit_the_reports_index
    visit provider_interface_reports_path
    expect(page).to have_current_path('/provider/reports')
  end

  def and_application_forms_exist_for_the_provider
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(25.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'White', 'disabilities' => ['Long-term illness'], 'sex' => 'female' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(35.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Prefer not to say', 'disabilities' => ['Long-term illness', 'Mental health condition'], 'sex' => 'other' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(23.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Mixed or multiple ethnic groups', 'disabilities' => ['Mental health condition'], 'sex' => 'female' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(52.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Asian or Asian British', 'disabilities' => ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'], 'sex' => 'female' }, application_choices: [create(:application_choice, :accepted, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(42.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Mixed or multiple ethnic groups', 'disabilities' => ['Autistic spectrum condition or another condition affecting speech, language, communication or social skills'], 'sex' => 'Prefer not to say' }, application_choices: [create(:application_choice, :recruited, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(32.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Prefer not to say', 'disabilities' => ['Prefer not to say'], 'sex' => 'other' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(24.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'White', 'disabilities' => ['I do not have any of these disabilities or health conditions'], 'sex' => 'female' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(37.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Mixed or multiple ethnic groups', 'disabilities' => ['I do not have any of these disabilities or health conditions'], 'sex' => 'male' }, application_choices: [create(:application_choice, :interviewing, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(36.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'Prefer not to say', 'disabilities' => ['I do not have any of these disabilities or health conditions'], 'sex' => 'female' }, application_choices: [create(:application_choice, :accepted, provider_ids: [@provider.id])])
    create(:application_form, submitted_at: Time.zone.now, recruitment_cycle_year: current_year, date_of_birth: Date.new(25.years.ago.year, 1, 1), equality_and_diversity: { 'ethnic_group' => 'White', 'disabilities' => ['I do not have any of these disabilities or health conditions'], 'sex' => 'male' }, application_choices: [create(:application_choice, :recruited, provider_ids: [@provider.id])])
  end

  def given_a_provider_and_provider_user_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
  end

  def and_i_click_on_sex_disability_ethnicity_and_age_of_candidates
    page.find_link(
      'Sex, disability, ethnicity and age of candidates',
      href: provider_interface_reports_provider_diversity_report_path(provider_id: @provider),
    ).click
  end

  def and_i_am_signed_in_as_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
    expect(page).to have_current_path('/provider/applications')
  end

  def then_i_see_the_sex_disability_ethnicity_and_age_report_for_the_providers_candidates
    expect(page).to have_element(
      :h1,
      text: "#{@provider.name} Sex, disability, ethnicity and age of candidates for #{current_timetable.cycle_range_name}",
    )
    expect(page).to have_element(:h2, text: 'About this data')
    expect(page).to have_element(
      :p,
      text: "This data comes from candidates who submitted an application from #{current_timetable.apply_opens_at.to_fs(:govuk_date)}",
    )
    expect(page).to have_element(
      :p,
      text: 'The sex, disability and ethnicity data comes from candidates who filled in a questionnaire when they applied to your organisation.',
    )
    expect(page).to have_element(
      :p,
      text: "The data for age is from all candidates. It's based on each candidate’s age on #{Time.zone.today.to_fs(:govuk_date)}. This data comes from the candidate’s date of birth, which they must enter as part of their application.",
    )
    expect(page).to have_element(:h3, text: 'How candidates are asked about their disabilities and health conditions')
    expect(page).to have_element(
      :p,
      text: 'Candidates are asked if they have a disability or health condition. If they do, they can select a type from a list. They can select more than one type or select ‘prefer not to say’.',
    )
    expect(page).to have_element(:h3, text: 'How candidates are asked about their ethnicity')
    expect(page).to have_element(
      :p,
      text: 'Candidates are asked to select an ethnic group, such as ‘Asian or Asain British’. They can also select ‘prefer not to say’.',
    )
    expect(page).to have_element(
      :p,
      text: 'If the candidate selects an ethnic group, then they can select a more specific background such as ‘Bangladeshi’. They can also select ‘prefer not to say’.',
    )
  end

  def and_i_see_the_sex_data_table
    expect(page).to have_element(:h2, text: 'Sex')
    within('#sex-table') do
      rows = page.all('tr')
      expect(rows[0].text).to eq('Sex Applied Offered Recruited Percentage recruited')
      expect(rows[1].text).to eq("Female\n5 2 0 0%")
      expect(rows[2].text).to eq("Male\n2 1 1 50%")
      expect(rows[3].text).to eq("Other\n2 0 0 0%")
      expect(rows[4].text).to eq("Prefer not to say\n1 1 1 100%")
      expect(rows[5].text).to eq('Total 10 4 2 -')
    end
  end

  def and_i_see_the_disability_data_tables
    expect(page).to have_element(:h2, text: 'Disability and health conditions')
    expect(page).to have_element(
      :p,
      text: 'This question is separate from asking candidates if they need additional support with their application or while they train.',
    )
    expect(page).to have_element(:h3, text: 'Candidates who declared a disability or health condition')
    within('#disability-declaration-table') do
      rows = page.all('tr')
      expect(rows[0].text).to eq('Disability declaration Applied Offered Recruited Percentage recruited')
      expect(rows[1].text).to eq("At least one disability or health condition declared\n5 2 1 20%")
      expect(rows[2].text).to eq("I do not have any of these disabilities or health conditions\n4 2 1 25%")
      expect(rows[3].text).to eq("Prefer not to say\n1 0 0 0%")
      expect(rows[4].text).to eq('Total 10 4 2 -')
    end
    expect(page).to have_element(:h3, text: 'Declared disability or health condition')
    expect(page).to have_element(
      :p,
      text: 'Candidates can select multiple disabilities or health conditions, so the numbers may not match the totals.',
    )
    within('#disability-or-health-condition-table') do
      rows = page.all('tr')
      expect(rows[0].text).to eq('Disability or health condition Applied Offered Recruited Percentage recruited')
      expect(rows[1].text).to eq("Autistic spectrum condition or another condition affecting speech, language, communication or social skills\n2 2 1 50%")
      expect(rows[2].text).to eq("Blindness or a visual impairment not corrected by glasses\n0 0 0 -")
      expect(rows[3].text).to eq("Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood\n0 0 0 -")
      expect(rows[4].text).to eq("Deafness or a serious hearing impairment\n0 0 0 -")
      expect(rows[5].text).to eq("Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference\n0 0 0 -")
      expect(rows[6].text).to eq("Long-term illness\n2 0 0 0%")
      expect(rows[7].text).to eq("Mental health condition\n2 0 0 0%")
      expect(rows[8].text).to eq("Physical disability or mobility issue\n0 0 0 -")
      expect(rows[9].text).to eq("Another disability, health condition or impairment affecting daily life\n0 0 0 -")
      expect(rows[10].text).to eq('Total 6 2 1 -')
    end
  end

  def and_i_see_the_ethnicity_data_table
    expect(page).to have_element(:h2, text: 'Ethnicity')
    within('#ethnic-group-table') do
      rows = page.all('tr')
      expect(rows[0].text).to eq('Ethnic group Applied Offered Recruited Percentage recruited')
      expect(rows[1].text).to eq("Asian or Asian British\n1 1 0 0%")
      expect(rows[2].text).to eq("Black, African, Black British or Caribbean\n0 0 0 -")
      expect(rows[3].text).to eq("Mixed or multiple ethnic groups\n3 1 1 33%")
      expect(rows[4].text).to eq("White\n3 1 1 33%")
      expect(rows[5].text).to eq("Another ethnic group\n0 0 0 -")
      expect(rows[6].text).to eq("Prefer not to say\n3 1 0 0%")
      expect(rows[7].text).to eq('Total 10 4 2 -')
    end
  end

  def and_i_see_the_age_data_table
    expect(page).to have_element(:h2, text: 'Age')
    within('#age-group-table') do
      rows = page.all('tr')
      expect(rows[0].text).to eq('Age group Applied Offered Recruited Percentage recruited')
      expect(rows[1].text).to eq("18 to 24\n2 0 0 0%")
      expect(rows[2].text).to eq("25 to 34\n3 1 1 33%")
      expect(rows[3].text).to eq("35 to 44\n4 2 1 25%")
      expect(rows[4].text).to eq("45 to 54\n1 1 0 0%")
      expect(rows[5].text).to eq("55 to 64\n0 0 0 -")
      expect(rows[6].text).to eq("65 or over\n0 0 0 -")
      expect(rows[7].text).to eq('Total 10 4 2 -')
    end
  end
end
