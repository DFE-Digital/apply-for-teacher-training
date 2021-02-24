require 'rails_helper'

RSpec.describe CandidateInterface::OtherQualificationTypeForm do
  let(:error_message_scope) do
    'activemodel.errors.models.candidate_interface/other_qualification_type_form.attributes.'
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:qualification_type) }
    it { is_expected.to validate_length_of(:other_uk_qualification_type).is_at_most(100) }
  end

  describe '#initialize' do
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

    context 'the qualification type is being updated from a non-uk qualification to a uk qualification' do
      it 'assigns an empty string to the non_uk attributes' do
        form = CandidateInterface::OtherQualificationTypeForm.new(
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
end
