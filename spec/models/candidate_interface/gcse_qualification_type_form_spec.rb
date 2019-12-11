require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationTypeForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:qualification_type) }

    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
  end

  describe '#save_base' do
    it 'return false if not valid' do
      application_form = double

      form = CandidateInterface::GcseQualificationTypeForm.new({})
      expect(form.save_base(application_form)).to eq(false)
    end

    it 'creates a new qualification if valid' do
      application_form = create(:application_form)

      form = CandidateInterface::GcseQualificationTypeForm
                                  .new(subject: 'maths', level: 'gcse', qualification_type: 'gcse')

      form.save_base(application_form)

      expect(form.subject).to eq('maths')
      expect(form.level).to eq('gcse')
      expect(form.qualification_type).to eq('gcse')
    end

    it 'builds the Form from the qualification model' do
      application_form = create(:application_form)
      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'gcse',
        )

      form = CandidateInterface::GcseQualificationTypeForm.build_from_qualification(qualification)

      expect(qualification.level).to eq 'gcse'
      expect(qualification.subject).to eq 'maths'
      expect(qualification.qualification_type).to eq 'gcse'
      expect(qualification.id).to eq qualification.id
      expect(form.new_record?).to be false
    end

    context 'the type of qualification is other_uk' do
      it 'gets error if other_uk_qualification_type is empty' do
        application_form = create(:application_form)
        qualification = application_form.application_qualifications.create!(
          level: 'gcse',
          subject: 'maths',
          qualification_type: 'other_uk',
          )

        form = CandidateInterface::GcseQualificationTypeForm.build_from_qualification(qualification)

        expect(form.valid?).to eq false
        expect(form.errors[:other_uk_qualification_type]).to include('Enter the type of qualification')
      end
    end

    it 'update the existing qualification model' do
      application_form = create(:application_form)
      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'gcse',
        )

      form = CandidateInterface::GcseQualificationTypeForm.build_from_qualification(qualification)

      form.qualification_type = 'gce_o_level'

      form.save_base(application_form)

      expect(form.errors).to be_empty
      expect(qualification.reload.qualification_type).to eq 'gce_o_level'
    end
  end
end
