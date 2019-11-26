require 'rails_helper'
require 'csv'

RSpec.feature 'Import references' do
  scenario 'Support agent imports a CSV' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_support_page

    when_i_click_on_import_references
    then_i_should_see_an_import_references_form

    when_i_import_references_without_uploading_a_csv_file
    then_i_should_see_an_error

    when_i_import_a_file_thats_not_a_csv
    then_i_should_see_an_error

    when_i_import_a_csv_file
    then_i_should_see_which_references_were_imported

    when_i_click_on_an_application
    then_i_should_see_the_imported_references
    and_the_applications_have_progressed_to_application_complete
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_there_are_applications_in_the_system
    @completed_applications = create_list(:completed_application_form, 3)
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_import_references
    click_on 'Import references'
  end

  def then_i_should_see_an_import_references_form
    expect(page).to have_content 'Import references'
    expect(page).to have_content 'CSV file'
  end

  def when_i_import_references_without_uploading_a_csv_file
    click_on 'Import references'
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'You must upload a CSV file'
  end

  def when_i_import_a_file_thats_not_a_csv
    txt_file = Tempfile.new(['txt_file', '.txt'])
    attach_file('CSV file', txt_file.path)
    click_on 'Import references'
  end

  def when_i_import_a_csv_file
    csv_file = Tempfile.new(['csv_file', '.csv'])
    CSV.open(csv_file, 'w') do |csv|
      @completed_applications.each do |application_form|
        application_form.references.each do |reference|
          csv << ['', reference.id, reference.email_address, reference.name, application_form.first_name, 'Imported feedback', 'I confirm']
        end
      end

      csv << ['', 'not an ID', 'not-a-reference@email.com', '', '', 'Bad data', 'I confirm']
    end

    attach_file('CSV file', csv_file.path)
    click_on 'Import references'
  end

  def then_i_should_see_which_references_were_imported
    expect(page).to have_content 'References imported'
    expect(page).to have_content '6 updated, 1 failed'
    expect(page).to have_content 'No application found for reference with ID \'not an ID\''
  end

  def when_i_click_on_an_application
    click_on @completed_applications.first.candidate.email_address, match: :first
  end

  def then_i_should_see_the_imported_references
    expect(page).to have_content 'Imported feedback', count: 2
  end

  def and_the_applications_have_progressed_to_application_complete
    statuses = @completed_applications.flat_map(&:application_choices).map(&:status)
    expect(statuses.uniq).to eql(%w[application_complete])
  end
end
