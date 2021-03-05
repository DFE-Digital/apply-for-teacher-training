require 'rails_helper'

RSpec.describe SupportInterface::CandidateAutofillUsageExport do
  describe '#data_for_export' do
    context 'degree qualifications' do
      it 'returns a hash of candidates autofill usage' do
        application_form = create(:application_form, :minimum_info)
        degree_qualification = create(:degree_qualification, application_form: application_form)
        other_qualification = create(
          :other_qualification,
          application_form: application_form,
          grade: 'Pass',
          qualification_type: 'BTEC',
        )

        expect(described_class.new.data_for_export).to eq(
          expected_hash(
            degree_qualification: degree_qualification,
            other_qualification: other_qualification,
            free_text: false,
          ),
        )
      end
    end

    context 'Phase 2 applications' do
      it "does not return a hash of candidates' autofill info" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_2')
        create(:degree_qualification, application_form: application_form)

        expect(described_class.new.data_for_export).to be_empty
      end
    end

    context 'Candidate free text inputs' do
      it "returns true for 'free_text?' row" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_1')
        degree_qualification = create(:degree_qualification,
                                      grade: 'Not a HESA grade',
                                      subject: 'Not a HESA subject',
                                      institution_name: 'Not a HESA institution',
                                      qualification_type: 'Not a HESA qualification type',
                                      application_form: application_form)
        other_qualification = create(:other_qualification,
                                     grade: 'Not a HESA grade',
                                     subject: 'Not a HESA subject',
                                     institution_name: 'Not a HESA institution',
                                     qualification_type: 'Not a HESA qualification type',
                                     application_form: application_form)

        expect(described_class.new.data_for_export).to eq(
          expected_hash(
            degree_qualification: degree_qualification,
            other_qualification: other_qualification,
            free_text: true,
          ),
        )
      end
    end
  end

private

  def expected_hash(degree_qualification:, other_qualification:, free_text:)
    [
      {
        'Field' => 'Degree grade',
        'Value entered' => degree_qualification.grade,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
      {
        'Field' => 'Degree institution',
        'Value entered' => degree_qualification.institution_name,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
      {
        'Field' => 'Degree subject',
        'Value entered' => degree_qualification.subject,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
      {
        'Field' => 'Degree type',
        'Value entered' => degree_qualification.qualification_type,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
      {
        'Field' => 'Other grade',
        'Value entered' => other_qualification.grade,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
      {
        'Field' => 'Other type',
        'Value entered' => other_qualification.qualification_type,
        'Frequency' => 1,
        'Free text?' => free_text,
      },
    ]
  end
end
