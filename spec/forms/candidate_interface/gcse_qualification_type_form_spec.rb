require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationTypeForm, type: :model do
  describe 'validations' do
    let(:form) { subject }

    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:qualification_type) }

    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(100) }
    it { is_expected.to validate_length_of(:qualification_type).is_at_most(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH) }
    it { is_expected.to validate_length_of(:non_uk_qualification_type).is_at_most(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH) }
    it { is_expected.to validate_length_of(:subject).is_at_most(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH) }

    context 'when qualification_type is other_uk' do
      before { allow(form).to receive(:other_uk_qualification?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_uk_qualification_type) }
    end

    context 'when qualification_type is non_uk' do
      before { allow(form).to receive(:non_uk_qualification?).and_return(true) }

      it { is_expected.to validate_presence_of(:non_uk_qualification_type) }
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
    end
  end

  describe '#save' do
    it 'return false if not valid' do
      application_form = double

      form = described_class.new({})
      expect(form.save(application_form)).to be(false)
    end

    it 'creates a new qualification if valid' do
      application_form = create(:application_form)

      form = described_class.new(subject: 'maths', level: 'gcse', qualification_type: 'gcse')

      form.save(application_form)

      expect(form.subject).to eq('maths')
      expect(form.level).to eq('gcse')
      expect(form.qualification_type).to eq('gcse')
    end
  end

  describe '#update' do
    it 'return false if not valid' do
      application_form = double

      form = described_class.new({})
      expect(form.update(application_form)).to be(false)
    end

    it 'updates the qualification type and sets the appropriate values to nil' do
      qualification = create(:gcse_qualification, :missing_and_currently_completing)

      described_class.new(
        qualification_type: 'gcse',
        subject: qualification.qualification_type,
        level: qualification.level,
      ).update(qualification)

      expect(qualification.reload.qualification_type).to eq 'gcse'
      expect(qualification.non_uk_qualification_type).to be_nil
      expect(qualification.currently_completing_qualification).to be_nil
      expect(qualification.not_completed_explanation).to be_nil
      expect(qualification.missing_explanation).to be_nil
    end

    context 'when the qualification_type is changed' do
      it 'resets grade and constituent_grades' do
        qualification = create(:gcse_qualification, constituent_grades: { 'biology' => { grade: 'B' } })

        described_class.new(
          qualification_type: 'non_uk',
          non_uk_qualification_type: 'BTEC',
          subject: qualification.qualification_type,
          level: qualification.level,
        ).update(qualification)

        expect(qualification.grade).to be_nil
        expect(qualification.constituent_grades).to be_nil
      end
    end

    context 'when the qualification_type is not changed' do
      it 'does not reset grade or constituent_grades' do
        qualification = create(:gcse_qualification, grade: 'A', constituent_grades: { 'biology' => { grade: 'B', 'public_id' => 999999 } })

        described_class.new(
          qualification_type: qualification.qualification_type,
          subject: qualification.subject,
          level: qualification.level,
        ).update(qualification)

        expect(qualification.grade).to eq('A')
        expect(qualification.constituent_grades).to eq({ 'biology' => { 'grade' => 'B', 'public_id' => 999999 } })
      end
    end

    context 'when the qualification_type is updated from non_uk' do
      it 'updates the existing qualification and sets non_uk_qualification_type to nil' do
        qualification = create(:gcse_qualification, :non_uk)

        described_class.new(
          qualification_type: 'gcse',
          subject: qualification.qualification_type,
          level: qualification.level,
        ).update(qualification)

        expect(qualification.reload.qualification_type).to eq 'gcse'
        expect(qualification.non_uk_qualification_type).to be_nil
        expect(qualification.enic_reference).to be_nil
        expect(qualification.comparable_uk_qualification).to be_nil
      end
    end

    context 'when the qualification_type is updated from other_uk' do
      it 'updates the existing qualification and sets other_uk_qualification_type to nil' do
        qualification = create(:gcse_qualification, non_uk_qualification_type: 'BTEC')

        described_class.new(
          qualification_type: 'gcse',
          subject: qualification.qualification_type,
          level: qualification.level,
        ).update(qualification)

        expect(qualification.reload.qualification_type).to eq 'gcse'
        expect(qualification.other_uk_qualification_type).to be_nil
      end
    end

    context 'when the qualification type is updated to missing' do
      it 'updates the qualification type and resets the appropriate attributes' do
        qualification = create(
          :gcse_qualification,
          :multiple_english_gcses,
          grade: 'D',
          currently_completing_qualification: false,
          missing_explanation: 'I am going to resit',
        )

        described_class.new(
          qualification_type: 'missing',
          subject: qualification.qualification_type,
          level: qualification.level,
        ).update(qualification)

        expect(qualification.reload.qualification_type).to eq 'missing'
        expect(qualification.grade).to be_nil
        expect(qualification.constituent_grades).to be_nil
        expect(qualification.award_year).to be_nil
        expect(qualification.institution_name).to be_nil
        expect(qualification.institution_country).to be_nil
        expect(qualification.other_uk_qualification_type).to be_nil
        expect(qualification.non_uk_qualification_type).to be_nil
        expect(qualification.currently_completing_qualification).to be_nil
        expect(qualification.not_completed_explanation).to be_nil
        expect(qualification.missing_explanation).to be_nil
      end
    end
  end
end
