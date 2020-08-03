require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationTypeForm do
  describe '#validations' do
    context 'with a qualification type present' do
      it 'is valid' do
        expect(described_class.new(qualification_type: 'A level')).to be_valid
      end
    end

    context 'without a qualification type present' do
      it 'is not valid' do
        expect(described_class.new(qualification_type: nil)).not_to be_valid
      end
    end

    context 'with a type that is not in the available options' do
      it 'is not valid' do
        expect(described_class.new(qualification_type: 'Invalid qualification')).not_to be_valid
      end
    end

    context 'when the qualification type is Other and the international_other_qualifications feature flag is active' do
      it 'validates that other_uk_qualification is present' do
        FeatureFlag.activate('international_other_qualifications')
        valid_response = described_class.new(qualification_type: 'Other', other_uk_qualification_type: 'Access Course')
        invalid_response = described_class.new(qualification_type: 'Other')

        expect(valid_response).to be_valid
        expect(invalid_response).not_to be_valid
      end
    end

    context 'when the qualification type is non_uk' do
      it 'validates that non_uk_qualification is present' do
        valid_response = described_class.new(qualification_type: 'non_uk', non_uk_qualification_type: 'Olympic Gold Medalist')
        invalid_response = described_class.new(qualification_type: 'non_uk')

        expect(valid_response).to be_valid
        expect(invalid_response).not_to be_valid
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      application_form = double

      form = CandidateInterface::OtherQualificationTypeForm.new({})
      expect(form.save(application_form)).to eq(false)
    end

    it 'creates a new other qualification if valid' do
      application_form = create(:application_form)

      form = CandidateInterface::OtherQualificationTypeForm.new(qualification_type: 'Other', other_uk_qualification_type: 'Access Course')

      form.save(application_form)

      expect(application_form.application_qualifications.last.level).to eq('other')
      expect(application_form.application_qualifications.last.qualification_type).to eq('Other')
      expect(application_form.application_qualifications.last.other_uk_qualification_type).to eq('Access Course')
    end

    it 'creates a new non-uk qualification if valid' do
      application_form = create(:application_form)

      form = CandidateInterface::OtherQualificationTypeForm.new(qualification_type: 'non_uk', non_uk_qualification_type: 'Olympic Gold Medalist')

      form.save(application_form)

      expect(application_form.application_qualifications.last.level).to eq('other')
      expect(application_form.application_qualifications.last.qualification_type).to eq('non_uk')
      expect(application_form.application_qualifications.last.non_uk_qualification_type).to eq('Olympic Gold Medalist')
    end
  end

  describe '#update' do
    it 'returns false if not valid' do
      qualification = double

      form = CandidateInterface::OtherQualificationTypeForm.new({})
      expect(form.update(qualification)).to eq(false)
    end

    it 'updates an other UK qualification if valid' do
      qualification = create(:other_qualification)

      form = CandidateInterface::OtherQualificationTypeForm.new(qualification_type: 'Other', other_uk_qualification_type: 'Wood Chopper')

      form.update(qualification)

      expect(qualification.level).to eq('other')
      expect(qualification.qualification_type).to eq('Other')
      expect(qualification.other_uk_qualification_type).to eq('Wood Chopper')
    end

    it 'updates a non_uk qualification if valid' do
      qualification = create(:other_qualification)

      form = CandidateInterface::OtherQualificationTypeForm.new(qualification_type: 'non_uk', non_uk_qualification_type: 'Olympic Gold Medalist')

      form.update(qualification)

      expect(qualification.level).to eq('other')
      expect(qualification.qualification_type).to eq('non_uk')
      expect(qualification.non_uk_qualification_type).to eq('Olympic Gold Medalist')
    end
  end

  describe '#build_from_qualification' do
    let(:data) do
      {
        qualification_type: 'non_uk',
        other_uk_qualification_type: nil,
        non_uk_qualification_type: 'Olympic gold medalist',
      }
    end

    it 'creates an object based on the provided ApplicationQualification' do
      qualification = ApplicationQualification.new(data)
      personal_details = CandidateInterface::OtherQualificationTypeForm.build_from_qualification(
        qualification,
      )

      expect(personal_details).to have_attributes(data)
    end
  end
end
