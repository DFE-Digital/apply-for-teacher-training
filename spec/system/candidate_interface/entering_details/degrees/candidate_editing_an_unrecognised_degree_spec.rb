require 'rails_helper'

RSpec.describe 'Editing a degree' do
  include CandidateHelper

  it 'Candidate edits their degree', :with_cache do
    given_i_am_signed_in_with_one_login
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_to_change_my_subject_areas
    then_i_can_see_the_subject_area_page

    when_i_select_history
    and_i_click_on_save_and_continue
    then_i_see_a_validation_error

    when_i_unselect_all_subject_areas
    and_i_click_on_save_and_continue
    then_i_see_a_validation_error

    when_i_select_history
    and_i_select_art_and_design
    and_i_click_on_save_and_continue
    then_i_see_my_updated_degree

    when_i_click_to_change_my_subject_areas
    and_i_unselect_all_subject_areas
    and_i_select_none_of_these
    and_i_click_on_save_and_continue
    then_i_see_the_subject_areas_have_been_removed
  end

private

  def and_i_have_completed_the_degree_section
    @current_candidate.application_forms.destroy_all
    @application_form = create(:application_form, candidate: @current_candidate)
    @degree = create(:application_qualification,
                     level: 'degree',
                     qualification_type: 'Bachelor of Arts',
                     qualification_level: 'bachelor',
                     start_year: '2006',
                     award_year: '2009',
                     predicted_grade: false,
                     subject: 'Sausage making',
                     institution_name: 'University of Cambridge',
                     institution_country: nil,
                     grade: 'Aegrotat',
                     application_form: @application_form)
    DegreeSubjectGroup.create!(
      application_qualification: @degree,
      name: 'Art and design',
      subject_group_uuid: '4d782fe1-c896-436e-86b1-a6b6156780fd',
    )
    DegreeSubjectGroup.create!(
      application_qualification: @degree,
      name: 'Design and technology',
      subject_group_uuid: '3cfa92d4-31ad-4714-b603-5ec408b99bb2',
    )
    @application_form.update!(degrees_completed: true)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_click_to_change_my_subject_areas
    click_on 'Change subject areas'
  end
  alias_method :when_i_click_to_change_my_subject_areas, :and_i_click_to_change_my_subject_areas

  def then_i_can_see_the_subject_area_page
    expect(page).to have_element(:legend, text: 'Which subject areas best describe your degree?')
    subject_groups.each do |subject_group|
      expect(page).to have_field(subject_group.name, type: :checkbox, visible: :all)
    end
  end

  def and_i_select_art_and_design
    check 'Art and design'
  end

  def and_i_unselect_design_and_technology
    uncheck 'Design and technology'
  end

  def when_i_select_history
    check 'History'
  end

  def subject_groups
    @subject_groups ||= DfE::ReferenceData::DegreeSubjectRelevancyGroups::SUBJECT_GROUPS
                          .all_as_hash.values
                          .reject { |subject_area| subject_area.id == :schema }
  end

  def then_i_see_a_validation_error
    expect(page).to have_text('Select up to 2 subject areas')
  end

  def when_i_unselect_all_subject_areas
    subject_groups.each do |subject_group|
      uncheck subject_group.name
    end
  end
  alias_method :and_i_unselect_all_subject_areas, :when_i_unselect_all_subject_areas

  def then_i_see_my_updated_degree
    expect(page).to have_element(:h1, text: 'Check your degree')
    expect(page).to have_element(:h2, text: 'BA Sausage making')
    expect(page).to have_element(:p, text: 'Sausage making')
    expect(page).to have_text('Art and design')
    expect(page).to have_text('History')
  end

  def and_i_select_none_of_these
    check 'None of these'
  end

  def then_i_see_the_subject_areas_have_been_removed
    expect(page).to have_no_text('Subject areas')
  end
end
