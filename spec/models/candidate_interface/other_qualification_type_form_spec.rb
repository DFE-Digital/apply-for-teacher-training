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
  end

  describe '#save' do
    it 'return false if not valid' do
      application_form = double

      form = CandidateInterface::GcseQualificationTypeForm.new({})
      expect(form.save_base(application_form)).to eq(false)
    end

    it 'creates a new other qualification if valid' do
      application_form = create(:application_form)

      form = CandidateInterface::OtherQualificationTypeForm.new(qualification_type: 'Other')

      form.save(application_form)

      expect(application_form.application_qualifications.last.level).to eq('other')
      expect(application_form.application_qualifications.last.qualification_type).to eq('Other')
    end
  end
end
