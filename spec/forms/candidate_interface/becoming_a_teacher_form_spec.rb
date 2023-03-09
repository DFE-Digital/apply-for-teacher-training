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
      becoming_a_teacher = described_class.build_from_application(
        application_form,
      )

      expect(becoming_a_teacher).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      becoming_a_teacher = described_class.new

      expect(becoming_a_teacher.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = create(:application_form)
      becoming_a_teacher = described_class.new(form_data)

      expect(becoming_a_teacher.save(application_form)).to be(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe '#blank?' do
    it 'is blank when containing only whitespace' do
      becoming_a_teacher = described_class.new(becoming_a_teacher: ' ')
      expect(becoming_a_teacher).to be_blank
    end

    it 'is not blank when containing some text' do
      becoming_a_teacher = described_class.new(becoming_a_teacher: 'Test')
      expect(becoming_a_teacher).not_to be_blank
    end
  end

  describe 'validations' do
    let(:application_form) { create(:application_form) }

    before do
      FeatureFlag.activate(:one_personal_statement)
    end

    it { is_expected.not_to validate_presence_of(:becoming_a_teacher) }

    context 'new single personal statement' do
      before do
        application_form.update!(created_at: ApplicationForm::SINGLE_PERSONAL_STATEMENT_FROM + 1.day)
        @valid_text = Faker::Lorem.sentence(word_count: 1000)
        @invalid_text = Faker::Lorem.sentence(word_count: 1001)
      end

      subject { described_class.build_from_application(application_form) }

      it { is_expected.to allow_value(@valid_text).for(:becoming_a_teacher) }
      it { is_expected.not_to allow_value(@invalid_text).for(:becoming_a_teacher) }
    end

    context 'old personal statement' do
      before do
        application_form.update!(created_at: ApplicationForm::SINGLE_PERSONAL_STATEMENT_FROM - 1.day)
        @valid_text = Faker::Lorem.sentence(word_count: 600)
        @invalid_text = Faker::Lorem.sentence(word_count: 601)
      end

      subject { described_class.build_from_application(application_form) }

      it { is_expected.to allow_value(@valid_text).for(:becoming_a_teacher) }
      it { is_expected.not_to allow_value(@invalid_text).for(:becoming_a_teacher) }
    end
  end
end
