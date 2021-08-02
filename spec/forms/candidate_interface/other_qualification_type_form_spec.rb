require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationTypeForm do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_type_form.attributes.'
  end

  let(:current_application) { create(:application_form) }
  let(:intermediate_data_service) do
    Class.new {
      def read
        {
          'qualification_type' => 'non_uk',
          'institution_country' => 'New Zealand',
          'non_uk_qualification_type' => 'German diploma',
        }
      end
    }.new
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(100) }

    context 'when a candidate has provided qualifications' do
      it 'returns true when qualification_type is in the `ALL_VALID_TYPES` constant' do
        described_class::ALL_VALID_TYPES.each do |valid_qualification_type|
          form = case valid_qualification_type
                 when 'Other'
                   described_class.new(nil, nil, 'qualification_type' => valid_qualification_type, other_uk_qualification_type: 'BTEC')
                 when 'non_uk'
                   described_class.new(nil, nil, 'qualification_type' => valid_qualification_type, non_uk_qualification_type: 'ZTEC')
                 else
                   described_class.new(nil, nil, 'qualification_type' => valid_qualification_type)
                 end

          expect(form.valid?).to eq true
        end
      end

      it 'returns false when the qualification_type is not in the `ALL_VALID_TYPES` constant' do
        form = described_class.new(nil, nil, 'qualification_type' => 'Invalid qual')

        expect(form.valid?).to eq false
      end

      it 'validates presence of `other_uk_qualification_type` when the candidate has selected other uk qualificaiton' do
        invalid_form = described_class.new(nil, nil, 'qualification_type' => 'Other')

        valid_form = described_class.new(nil, nil, 'qualification_type' => 'Other', 'other_uk_qualification_type' => 'BTEC')

        expect(invalid_form.valid?).to eq false
        expect(valid_form.valid?).to eq true
      end

      it 'validates presence of `non_uk_qualification_type` when the candidate has selected non uk qualificaiton' do
        invalid_form = described_class.new(nil, nil, 'qualification_type' => 'non_uk')

        valid_form = described_class.new(nil, nil, 'qualification_type' => 'non_uk', 'non_uk_qualification_type' => 'ZTEC')
        expect(invalid_form.valid?).to eq false
        expect(valid_form.valid?).to eq true
      end
    end

    context 'when a candidate has no other qualifications to add' do
      it 'does not validate that qualification_type is in the `ALL_VALID_TYPES`' do
        form = described_class.new(nil, nil, 'qualification_type' => 'no_other_qualifications')

        expect(form.valid?).to eq true
      end
    end
  end

  describe '#initialize' do
    context 'the qualification type is being updated from a non-uk qualification to a uk qualification' do
      it 'assigns an empty string to the non_uk attributes' do
        form = described_class.new(
          current_application,
          intermediate_data_service,
          'qualification_type' => 'GCSE',
          'non_uk_qualification_type' => 'German diploma',
        )

        expect(form.qualification_type).to eq('GCSE')
        expect(form.non_uk_qualification_type).to be_nil
        expect(form.institution_country).to be_nil
      end
    end
  end

  describe '#save_no_other_qualifications' do
    it 'does not update no_other_qualifications when invalid' do
      form = described_class.new
      expect(form.save_no_other_qualifications).to eq false
      expect(current_application.reload.no_other_qualifications).to eq false
    end

    it 'updates the application forms no_other_qualifications to true' do
      form = described_class.new(
        current_application,
        intermediate_data_service,
        'qualification_type' => 'no_other_qualifications',
      )

      expect(form.save_no_other_qualifications).to eq true
      expect(current_application.reload.no_other_qualifications).to eq true
    end
  end
end
