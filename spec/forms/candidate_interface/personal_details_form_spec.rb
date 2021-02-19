require 'rails_helper'

RSpec.describe CandidateInterface::PersonalDetailsForm, type: :model do
  let(:data) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      date_of_birth: Faker::Date.birthday,
    }
  end

  let(:form_data) do
    {
      first_name: data[:first_name],
      last_name: data[:last_name],
      day: data[:date_of_birth].day,
      month: data[:date_of_birth].month,
      year: data[:date_of_birth].year,
    }
  end

  describe '#name' do
    it 'concatenates the first name and last name' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      personal_details = CandidateInterface::PersonalDetailsForm.build_from_application(
        application_form,
      )

      expect(personal_details).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      personal_details = CandidateInterface::PersonalDetailsForm.new

      expect(personal_details.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      personal_details = CandidateInterface::PersonalDetailsForm.new(form_data)

      expect(personal_details.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe '#date_of_birth' do
    it 'return a nil for nil day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: nil, month: nil, year: nil)

      expect(personal_details.date_of_birth.day).to be_nil
      expect(personal_details.date_of_birth.month).to be_nil
      expect(personal_details.date_of_birth.year).to be_nil
    end

    it 'can return an invalid date object for invalid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: 99, month: 99, year: 99)

      expect(personal_details.date_of_birth.day).to eq(99)
      expect(personal_details.date_of_birth.month).to eq(99)
      expect(personal_details.date_of_birth.year).to eq(99)
    end

    it 'returns a date for a valid day/month/year' do
      personal_details = CandidateInterface::PersonalDetailsForm.new(day: '2', month: '8', year: '1990')

      expect(personal_details.date_of_birth).to eq(Date.new(1990, 8, 2))
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(60) }

    describe 'date of birth' do
      around do |example|
        Timecop.freeze(Time.zone.local(2019, 1, 1)) do
          example.run
        end
      end

      it 'is invalid if not well-formed' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '99', month: '99', year: '99',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a real date of birth'],
        )
      end

      it 'is invalid if the date is in the future' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '2', month: '8', year: '2999',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth that is in the past, for example 31 3 1980'],
        )
      end

      it 'is invalid if the candidate is younger than 16' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '2', month: '1', year: '2003',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to eq(
          ['Date of birth Enter a date of birth before 1 January 2003 – you must be over 16 years old to Apply for teacher training'],
        )
      end

      it 'is valid if the candidate is older than 16' do
        personal_details = CandidateInterface::PersonalDetailsForm.new(
          day: '31', month: '12', year: '2002',
        )

        personal_details.validate

        expect(personal_details.errors.full_messages_for(:date_of_birth)).to be_empty
      end
    end
  end
end
