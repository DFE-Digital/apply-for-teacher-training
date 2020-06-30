require 'rails_helper'

RSpec.describe CandidateInterface::DegreeYearForm, type: :model do
  describe 'award year' do
    ['a year', '200'].each do |invalid_date|
      it "is invalid if the award year is '#{invalid_date}'" do
        degree_form = described_class.new(award_year: invalid_date)
        error_message = t('activemodel.errors.models.candidate_interface/degree_year_form.attributes.award_year.invalid')

        degree_form.validate(:award_year)

        expect(degree_form.errors.full_messages_for(:award_year)).to eq(
          ["Award year #{error_message}"],
        )
      end
    end

    it 'is valid if the award year is 4 digits' do
      degree_form = described_class.new(award_year: '2009')
      error_message = t('activemodel.errors.models.candidate_interface/degree_year_form.attributes.award_year.invalid')

      degree_form.validate(:award_year)

      expect(degree_form.errors.full_messages_for(:award_year)).not_to eq(
        ["Award year #{error_message}"],
      )
    end

    it 'is invalid if the award year is more than one year into the future' do
      Timecop.freeze(Time.zone.local(2008, 1, 1)) do
        degree_form = described_class.new(award_year: '2010')

        degree_form.validate(:award_year)

        expect(degree_form.errors.full_messages_for(:award_year)).to eq(
          ['Award year Enter a year before 2010'],
        )
      end
    end
  end

  describe 'start year' do
    it 'is invalid if greater than the award year' do
      degree_form = described_class.new(start_year: '2009', award_year: '2008')
      error_message = t('activemodel.errors.models.candidate_interface/degree_year_form.attributes.start_year.greater_than_award_year')

      degree_form.validate(:start_year)

      expect(degree_form.errors.full_messages_for(:start_year)).to eq(
        ["Start year #{error_message}"],
      )
    end
  end
end
