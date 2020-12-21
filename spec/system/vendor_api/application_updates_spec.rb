require 'rails_helper'

RSpec.feature 'Application updated_at dates on the API' do
  scenario 'when different parts of the application are changed' do
    given_an_application_is_available_over_the_api
    when_i_retrieve_the_application_over_the_api
    then_the_last_public_update_date_should_be_the_same_as_the_updated_at_date

    Timecop.freeze(1.hour.from_now) do
      when_i_change_the_name_on_the_application_form
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(2.hours.from_now) do
      when_i_change_a_work_experience
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(3.hours.from_now) do
      when_i_change_a_volunteering_experience
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(4.hours.from_now) do
      when_i_change_a_degree
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(5.hours.from_now) do
      when_i_change_a_reference
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(6.hours.from_now) do
      when_i_add_an_english_proficiency_qualification
      then_the_last_public_update_date_should_change
    end

    Timecop.freeze(7.hours.from_now) do
      when_i_change_an_unrelated_field_on_the_application_form
      then_the_last_public_update_date_should_not_change
    end
  end

  def given_an_application_is_available_over_the_api
    @form = create(:completed_application_form,
                   work_experiences_count: 1,
                   volunteering_experiences_count: 1,
                   references_count: 1,
                   with_degree: true)
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: @form)
  end

  def then_the_last_public_update_date_should_be_the_same_as_the_updated_at_date
    @last_checked_updated_at_date = @application_choice.last_public_update_at
    expect(@last_checked_updated_at_date).to be_within(1.second).of @application_choice.updated_at
  end

  def then_the_last_public_update_date_should_change
    expect(@last_checked_updated_at_date).not_to eq @application_choice.reload.last_public_update_at
    @last_checked_updated_at_date = @application_choice.last_public_update_at
  end

  def then_the_last_public_update_date_should_not_change
    expect(@last_checked_updated_at_date).to eq @application_choice.last_public_update_at
  end

  def when_i_change_the_name_on_the_application_form
    @application_choice.application_form.update!(first_name: 'Betty', last_name: 'Boop')
  end

  def when_i_change_a_work_experience
    @application_choice.application_form.application_work_experiences.first.update!(start_date: Date.new(2010, 1, 1))
  end

  def when_i_change_a_volunteering_experience
    @application_choice.application_form.application_volunteering_experiences.first.update!(start_date: Date.new(2010, 1, 1))
  end

  def when_i_change_a_degree
    @application_choice.application_form.application_qualifications.degrees.first.update!(start_year: 1990)
  end

  def when_i_change_a_reference
    @application_choice.application_form.application_references.first.update!(name: 'Rihanna')
  end

  def when_i_add_an_english_proficiency_qualification
    create(:english_proficiency, :with_ielts_qualification, application_form: @form)
  end

  def when_i_change_an_unrelated_field_on_the_application_form
    @form.update(latitude: 99)
  end

  def when_i_retrieve_the_application_over_the_api
    api_token = VendorAPIToken.create_with_random_token!(provider: @application_choice.provider)
    page.driver.header 'Authorization', "Bearer #{api_token}"

    visit '/api/v1/applications?since=2019-01-01'

    @api_response = JSON.parse(page.body)
  end
end
