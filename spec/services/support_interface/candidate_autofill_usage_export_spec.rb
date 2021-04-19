require 'rails_helper'

RSpec.describe SupportInterface::CandidateAutofillUsageExport do
  describe 'documentation' do
    before do
      application_form = create(:application_form, :minimum_info)
      create(:degree_qualification, application_form: application_form)
    end

    it_behaves_like 'a data export'
  end

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
      it "does not return a hash of candidates' autofill usage" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_2')
        create(:degree_qualification, application_form: application_form)

        expect(described_class.new.data_for_export).to be_empty
      end
    end

    context 'Unsubmitted applications' do
      it "does not return a hash of candidates' autofill usage" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_1', submitted_at: nil)
        create(:degree_qualification, application_form: application_form)

        expect(described_class.new.data_for_export).to be_empty
      end
    end

    context 'Applications submitted before Dec 1, 2020' do
      it "does not return a hash of candidates' autofill usage" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_1', submitted_at: Date.new(2020, 11, 1))
        create(:degree_qualification, application_form: application_form)

        expect(described_class.new.data_for_export).to be_empty
      end
    end

    context 'Non UK qualifications' do
      it "does not return a hash of candidates' autofill usage" do
        application_form = create(:application_form, :minimum_info, phase: 'apply_1')
        create(:other_qualification, :non_uk, application_form: application_form)

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
        field: 'Degree grade',
        value_entered: degree_qualification.grade,
        frequency: 1,
        free_text?: free_text,
      },
      {
        field: 'Degree institution',
        value_entered: degree_qualification.institution_name,
        frequency: 1,
        free_text?: free_text,
      },
      {
        field: 'Degree subject',
        value_entered: degree_qualification.subject,
        frequency: 1,
        free_text?: free_text,
      },
      {
        field: 'Degree type',
        value_entered: degree_qualification.qualification_type,
        frequency: 1,
        free_text?: free_text,
      },
      {
        field: 'Other grade',
        value_entered: other_qualification.grade,
        frequency: 1,
        free_text?: free_text,
      },
      {
        field: 'Other type',
        value_entered: other_qualification.qualification_type,
        frequency: 1,
        free_text?: free_text,
      },
    ]
  end
end
