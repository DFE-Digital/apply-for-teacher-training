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
      personal_details = described_class.new(first_name: 'Bruce', last_name: 'Wayne')

      expect(personal_details.name).to eq('Bruce Wayne')
    end
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      personal_details = described_class.build_from_application(
        application_form,
      )

      expect(personal_details).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      personal_details = described_class.new

      expect(personal_details.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      personal_details = described_class.new(form_data)

      expect(personal_details.save(application_form)).to be(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }

    it { is_expected.to validate_length_of(:first_name).is_at_most(60) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(60) }

    describe 'date of birth' do
      let(:model) { described_class.new(day:, month:, year:) }

      it_behaves_like 'date_of_birth validations', verify_presence: true

      it 'is invalid on RangeError and does not raise' do
        expect {
          model = described_class.new(day: '9301305922083', month: '01', year: '2022')

          expect(model).not_to be_valid
        }.not_to raise_error
      end
    end
  end
end
