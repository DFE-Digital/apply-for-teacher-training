require 'rails_helper'

RSpec.describe ApplicationQualification, type: :model do
  it 'includes the fields for a degree, GCSE and other qualification level' do
    qualification = ApplicationQualification.new

    expect(qualification.attributes).to include(
      'level',
      'qualification_type',
      'subject',
      'grade',
      'predicted_grade',
      'start_year',
      'award_year',
      'institution_name',
      'institution_country',
      'awarding_body',
      'equivalency_details',
    )
  end

  describe 'level' do
    it 'only accepts degree, gcse and other' do
      %w[degree gcse other].each do |level|
        expect { ApplicationQualification.new(level: level) }.not_to raise_error
      end
    end

    it 'raises an error when level is invalid' do
      expect { ApplicationQualification.new(level: 'invalid_level') }
        .to raise_error ArgumentError, "'invalid_level' is not a valid level"
    end
  end

  describe 'auditing', with_audited: true do
    it 'creates audit entries' do
      application_form = create :application_form
      application_qualification = create :application_qualification, application_form: application_form
      expect(application_qualification.audits.count).to eq 1
      expect {
        application_qualification.update!(subject: 'Rocket Surgery')
      }.to change { application_qualification.audits.count }.by(1)
    end

    it 'creates an associated object in each audit record' do
      application_form = create :application_form
      application_qualification = create :application_qualification, application_form: application_form
      expect(application_qualification.audits.last.associated).to eq application_qualification.application_form
    end
  end

  describe '#incomplete_degree_information?' do
    it 'returns false if not a degree' do
      qualification = build_stubbed(:gcse_qualification)

      expect(qualification.incomplete_degree_information?).to eq false
    end

    it 'returns false if all expected information is present' do
      qualification = build_stubbed(:degree_qualification)

      expect(qualification.incomplete_degree_information?).to eq false
    end

    it 'returns true if the predicted_grade boolean is not present' do
      qualification = build_stubbed(:degree_qualification)
      qualification.predicted_grade = nil

      expect(qualification.incomplete_degree_information?).to eq true
    end

    it 'returns true if any expected information is missing' do
      qualification = build_stubbed(:degree_qualification)

      ApplicationQualification::EXPECTED_DEGREE_DATA.each do |field|
        qualification.send("#{field}=", nil)
        expect(qualification.incomplete_degree_information?).to eq true
        qualification.send("#{field}=", '')
        expect(qualification.incomplete_degree_information?).to eq true
      end
    end
  end

  describe '#incomplete_other_qualification?' do
    context 'when a non_uk qualification' do
      it 'returns false if not an other_qualification' do
        qualification = build_stubbed(:gcse_qualification)

        expect(qualification.incomplete_other_qualification?).to eq false
      end

      it 'returns false if all expected information is present' do
        qualification = build_stubbed(:other_qualification, :non_uk, grade: nil, subject: nil)

        expect(qualification.incomplete_other_qualification?).to eq false
      end

      it 'returns true if any expected information is missing' do
        qualification = build_stubbed(:other_qualification)

        ApplicationQualification::EXPECTED_OTHER_QUALIFICATION_DATA.each do |field|
          qualification.send("#{field}=", nil)
          expect(qualification.incomplete_other_qualification?).to eq true
          qualification.send("#{field}=", '')
          expect(qualification.incomplete_other_qualification?).to eq true
        end
      end
    end

    context 'for UK qualifications' do
      it 'returns false if not an other_qualification' do
        qualification = build_stubbed(:gcse_qualification)

        expect(qualification.incomplete_other_qualification?).to eq false
      end

      it 'returns false if all expected information is present' do
        qualification = build_stubbed(:other_qualification)

        expect(qualification.incomplete_other_qualification?).to eq false
      end

      it 'returns true if any expected information is missing' do
        qualification = build_stubbed(:other_qualification)

        ApplicationQualification::EXPECTED_OTHER_QUALIFICATION_DATA.each do |field|
          qualification.send("#{field}=", nil)
          expect(qualification.incomplete_other_qualification?).to eq true
          qualification.send("#{field}=", '')
          expect(qualification.incomplete_other_qualification?).to eq true
        end
      end
    end
  end

  describe '#naric_reference_choice' do
    it 'returns No when naric reference is nil and grade is present' do
      qualification = build_stubbed(:application_qualification, naric_reference: nil, grade: 'c')
      expect(qualification.naric_reference_choice).to eq('No')
    end

    it 'returns Yes when reference number provided' do
      qualification = build_stubbed(:application_qualification, naric_reference: '12345')
      expect(qualification.naric_reference_choice).to eq('Yes')
    end

    it 'returns nil when field not submitted' do
      qualification = build_stubbed(:application_qualification, naric_reference: nil, grade: nil)
      expect(qualification.naric_reference_choice).to eq(nil)
    end
  end

  describe '#set_grade' do
    it 'sets grade to not_applicable and other grade to nil when grade is not_applicable' do
      qualification = build_stubbed(:gcse_qualification, grade: 'n/a')
      expect(qualification.set_grade).to eq 'not_applicable'
    end

    it 'sets grade to not_applicable and other grade to nil when grade is unknown' do
      qualification = build_stubbed(:gcse_qualification, grade: 'unknown')
      expect(qualification.set_grade).to eq 'unknown'
    end

    it 'sets grade to other and other grade to grades value when grade is another value' do
      qualification = build_stubbed(:gcse_qualification, grade: 'D')
      expect(qualification.set_grade).to eq 'other'
    end
  end

  describe '#set_other_grade' do
    it 'returns nil when grade is not_applicable' do
      qualification = build_stubbed(:gcse_qualification, grade: 'n/a')
      expect(qualification.set_other_grade).to eq nil
    end

    it 'returns nil when grade is unknown' do
      qualification = build_stubbed(:gcse_qualification, grade: 'unknown')
      expect(qualification.set_other_grade).to eq nil
    end

    it 'returns grade when grade is another value' do
      qualification = build_stubbed(:gcse_qualification, grade: 'D')
      expect(qualification.set_other_grade).to eq 'D'
    end
  end
end
