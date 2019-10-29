require 'rails_helper'

RSpec.describe CandidateInterface::WorkExperienceForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:organisation) }
    it { is_expected.to validate_presence_of(:details) }
    it { is_expected.to validate_presence_of(:working_with_children) }
    it { is_expected.to validate_presence_of(:commitment) }

    it { is_expected.to validate_length_of(:role).is_at_most(60) }
    it { is_expected.to validate_length_of(:organisation).is_at_most(60) }


    okay_text = Faker::Lorem.sentence(word_count: 150)
    long_text = Faker::Lorem.sentence(word_count: 151)

    it { is_expected.to allow_value(okay_text).for(:details) }
    it { is_expected.not_to allow_value(long_text).for(:details) }

    describe 'start date' do
      it 'is invalid if not well-formed' do
        work_experience = CandidateInterface::WorkExperienceForm.new(
          start_date_month: '99', start_date_year: '99',
        )

        work_experience.validate

        expect(work_experience.errors.full_messages_for(:start_date)).to eq(
          ['Start date Enter a start date in the correct format, for example 5 2018'],
        )
      end

      it 'is invalid if the date is after the end date' do
        work_experience = CandidateInterface::WorkExperienceForm.new(
          start_date_month: '5', start_date_year: '2018',
          end_date_month: '5', end_date_year: '2017'
        )

        work_experience.validate

        expect(work_experience.errors.full_messages_for(:start_date)).to eq(
          ['Start date Enter a start date that is before the end date'],
        )
      end
    end
  end
end
