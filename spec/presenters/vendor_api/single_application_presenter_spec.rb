require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  describe '#candidate' do
    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form) do |form|
        form.first_nationality = 'British'
        form.second_nationality = 'American'
      end
      application_choice = create(:application_choice, application_form: application_form)
      single_application_presenter = VendorApi::SingleApplicationPresenter.new(application_choice)

      expect(single_application_presenter.as_json[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end

  describe 'qualifications' do
    it 'returns qualifications in the correct format' do
      application_form = create(:completed_application_form, qualifications_count: 0)
      application_form.application_qualifications << build(:application_qualification,
                                                           level: 'degree',
                                                           qualification_type: 'BA',
                                                           subject: 'History',
                                                           grade: 'upper_second',
                                                           predicted_grade: false,
                                                           award_year: '1992',
                                                           institution_name: 'Mallowtown TAFE',
                                                           institution_country: 'GB',
                                                           awarding_body: 'Falconholt TAFE',
                                                           equivalency_details: 'UK qualification')

      application_form.application_qualifications << build(:application_qualification,
                                                           level: 'gcse',
                                                           qualification_type: 'Gcse',
                                                           subject: 'Art',
                                                           grade: 'A',
                                                           predicted_grade: false,
                                                           award_year: '1990',
                                                           institution_name: 'Mallowpond College',
                                                           institution_country: 'GB',
                                                           awarding_body: 'Mallowpond College',
                                                           equivalency_details: 'UK qualification')

      application_form.application_qualifications << build(:application_qualification,
                                                           level: 'other',
                                                           qualification_type: 'Gcse',
                                                           subject: 'Music',
                                                           grade: 'B',
                                                           predicted_grade: false,
                                                           award_year: '1989',
                                                           institution_name: 'Mallowpond College',
                                                           institution_country: 'GB',
                                                           awarding_body: 'Mallowpond College',
                                                           equivalency_details: 'UK qualification')
      application_choice = create(:application_choice, application_form: application_form)
      single_application_presenter = VendorApi::SingleApplicationPresenter.new(application_choice)

      expect(single_application_presenter.as_json[:attributes][:qualifications][:degrees].first[:subject]).to eq('History')
      expect(single_application_presenter.as_json[:attributes][:qualifications][:gcses].first[:subject]).to eq('Art')
      expect(single_application_presenter.as_json[:attributes][:qualifications][:other_qualifications].first[:subject]).to eq('Music')
    end
  end
end
