require 'rails_helper'

RSpec.describe CandidateInterface::BecomingATeacherForm, type: :model do
  let(:data) do
    {
      becoming_a_teacher: Faker::Lorem.paragraph_by_chars(number: 200),
    }
  end

  let(:form_data) do
    {
      becoming_a_teacher: data[:becoming_a_teacher],
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      becoming_a_teacher = CandidateInterface::BecomingATeacherForm.build_from_application(
        application_form,
      )

      expect(becoming_a_teacher).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      becoming_a_teacher = CandidateInterface::BecomingATeacherForm.new

      expect(becoming_a_teacher.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      becoming_a_teacher = CandidateInterface::BecomingATeacherForm.new(form_data)

      expect(becoming_a_teacher.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:becoming_a_teacher) }

    valid_text = Faker::Lorem.sentence(word_count: 600)
    invalid_text = Faker::Lorem.sentence(word_count: 601)

    it { is_expected.to allow_value(valid_text).for(:becoming_a_teacher) }
    it { is_expected.not_to allow_value(invalid_text).for(:becoming_a_teacher) }
  end
end
