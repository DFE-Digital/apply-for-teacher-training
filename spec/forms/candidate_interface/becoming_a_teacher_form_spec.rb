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
  let(:application_form) { create(:application_form) }

  subject(:becoming_a_teacher) { described_class.new(form_data) }

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
    let(:application_form) { create(:application_form) }

    context 'save succeeds' do
      it 'updates the provided ApplicationForm', :aggregate_failures do
        expect(becoming_a_teacher.save(application_form)).to be(true)
        expect(application_form).to have_attributes(data)
      end
    end

    context 'when save fails' do
      let(:application_form) do
        create(:application_form, becoming_a_teacher: nil, application_choices: [create(:application_choice)])
      end

      before { allow_any_instance_of(ApplicationForm).to receive(:update!).and_raise(ActiveRecord::LockWaitTimeout) } # rubocop:disable RSpec/AnyInstance

      it 'does not update the application_form' do
        begin
          becoming_a_teacher.save(application_form)
        rescue ActiveRecord::LockWaitTimeout
          nil
        end
        expect(application_form.reload.becoming_a_teacher).to be_nil
      end

      it 'returns nil' do
        begin
          result = becoming_a_teacher.save(application_form)
        rescue ActiveRecord::LockWaitTimeout
          nil
        end
        expect(result).to be_nil
      end
    end

    context 'when the form is invalid' do
      let(:data) do
        { becoming_a_teacher: Faker::Lorem.sentence(word_count: 1001) }
      end

      it 'returns false' do
        expect(becoming_a_teacher.save(application_form)).to be(false)
      end
    end
  end

  describe 'validations' do
    let(:application_form) { create(:application_form) }

    it { is_expected.to validate_presence_of(:becoming_a_teacher) }

    context 'personal statement' do
      before do
        @valid_text = Faker::Lorem.sentence(word_count: 1000)
        @invalid_text = Faker::Lorem.sentence(word_count: 1001)
      end

      subject { described_class.build_from_application(application_form) }

      it { is_expected.to allow_value(@valid_text).for(:becoming_a_teacher) }
      it { is_expected.not_to allow_value(@invalid_text).for(:becoming_a_teacher) }
    end
  end
end
