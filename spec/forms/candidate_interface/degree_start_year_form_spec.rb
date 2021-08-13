require 'rails_helper'

RSpec.describe CandidateInterface::DegreeStartYearForm, type: :model do
  describe 'start year' do
    it 'is invalid if greater than the award year' do
      degree = build(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: false,
        award_year: '2008',
      )

      degree_form = described_class.new(degree: degree, start_year: '2009')
      error_message = t('activemodel.errors.models.candidate_interface/degree_start_year_form.attributes.start_year.greater_than_award_year')

      degree_form.validate(:start_year)

      expect(degree_form.errors.full_messages_for(:start_year)).to eq(
        ["Start year #{error_message}"],
      )
    end
  end
end
