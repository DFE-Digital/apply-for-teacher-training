require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationTypeForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:qualification_type) }

    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(100) }
    it { is_expected.to validate_length_of(:qualification_type).is_at_most(255) }
    it { is_expected.to validate_length_of(:subject).is_at_most(255) }
  end

  describe '#save' do
    it 'return false if not valid' do
      application_form = double

      form = described_class.new({})
      expect(form.save(application_form)).to eq(false)
    end

    it 'creates a new qualification if valid' do
      application_form = create(:application_form)

      form = described_class
                                  .new(subject: 'maths', level: 'gcse', qualification_type: 'gcse')

      form.save(application_form)

      expect(form.subject).to eq('maths')
      expect(form.level).to eq('gcse')
      expect(form.qualification_type).to eq('gcse')
    end

    it 'saves when non_uk_qualification_type is present' do
      application_form = create(:application_form)
      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'non_uk',
        non_uk_qualification_type: 'High School Diploma',
      )

      form = described_class.build_from_qualification(qualification)
      form.save(application_form)

      expect(application_form.application_qualifications.first.qualification_type).to eq 'non_uk'
      expect(application_form.application_qualifications.first.non_uk_qualification_type).to eq 'High School Diploma'
    end

    context 'the type of qualification is other_uk' do
      it 'does not save if the other_uk_qualification_type is empty' do
        application_form = create(:application_form)
        qualification = application_form.application_qualifications.create!(
          level: 'gcse',
          subject: 'maths',
          qualification_type: 'other_uk',
        )

        form = described_class.build_from_qualification(qualification)

        expect(form.valid?).to eq false
        expect(form.errors[:other_uk_qualification_type]).to include('Enter the type of qualification')
      end
    end

    context 'the type of qualification is non_uk ' do
      it 'does not save if non_uk_qualification_type is empty' do
        application_form = create(:application_form)
        qualification = application_form.application_qualifications.create!(
          level: 'gcse',
          subject: 'maths',
          qualification_type: 'non_uk',
        )

        form = described_class.build_from_qualification(qualification)

        expect(form.valid?).to eq false
        expect(form.errors[:non_uk_qualification_type]).to include('Enter the type of qualification')
      end
    end
  end

  describe '#build_from_qualification' do
    it 'builds the Form from the qualification model' do
      application_form = create(:application_form)
      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'gcse',
      )

      form = described_class.build_from_qualification(qualification)

      expect(form.level).to eq 'gcse'
      expect(form.subject).to eq 'maths'
      expect(form.qualification_type).to eq 'gcse'
      expect(form.qualification_id).to eq qualification.id
    end
  end

  describe '#update' do
    it 'return false if not valid' do
      application_form = double

      form = described_class.new({})
      expect(form.update(application_form)).to eq(false)
    end

    it 'update the existing qualification model' do
      application_form = create(:application_form)
      qualification = application_form.application_qualifications.create!(
        level: 'gcse',
        subject: 'maths',
        qualification_type: 'gcse',
      )

      form = described_class.build_from_qualification(qualification)

      form.qualification_type = 'gce_o_level'

      form.update(qualification)

      expect(form.errors).to be_empty
      expect(qualification.reload.qualification_type).to eq 'gce_o_level'
    end
  end
end
