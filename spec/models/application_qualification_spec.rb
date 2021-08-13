require 'rails_helper'

RSpec.describe ApplicationQualification, type: :model do
  it 'includes the fields for a degree, GCSE and other qualification level' do
    qualification = described_class.new

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
      'equivalency_details',
    )
  end

  describe 'level' do
    it 'only accepts degree, gcse and other' do
      %w[degree gcse other].each do |level|
        expect { described_class.new(level: level) }.not_to raise_error
      end
    end

    it 'raises an error when level is invalid' do
      expect { described_class.new(level: 'invalid_level') }
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

  describe '#enic_reference?' do
    it 'returns No when enic reference is nil and grade is present' do
      qualification = build_stubbed(:application_qualification, enic_reference: nil, grade: 'c')
      expect(qualification.enic_reference?).to eq('No')
    end

    it 'returns Yes when reference number provided' do
      qualification = build_stubbed(:application_qualification, enic_reference: '12345')
      expect(qualification.enic_reference?).to eq('Yes')
    end

    it 'returns nil when field not submitted' do
      qualification = build_stubbed(:application_qualification, enic_reference: nil, grade: nil)
      expect(qualification.enic_reference?).to eq(nil)
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

  describe 'composite_equivalency_details' do
    it 'returns a sentence describing equivalency details for a degree' do
      degree = build_stubbed(
        :degree_qualification,
        qualification_type: 'Bachelor degree',
        international: true,
        institution_country: 'US',
        enic_reference: '0123456789',
        comparable_uk_degree: 'bachelor_honours_degree',
        equivalency_details: 'equivalent to a UK BSc',
      )

      expect(degree.composite_equivalency_details).to eq('Enic: 0123456789 - bachelor_honours_degree - equivalent to a UK BSc')
    end

    it 'returns a sentence describing equivalency details for a GCSE level qualification' do
      gcse = build_stubbed(
        :gcse_qualification,
        qualification_type: 'scottish_national_5',
        equivalency_details: 'equivalent to a GCSE',
      )

      expect(gcse.composite_equivalency_details).to eq('equivalent to a GCSE')
    end

    it 'returns nil if there is no data to show' do
      gcse = build_stubbed(:gcse_qualification, equivalency_details: nil)

      expect(gcse.composite_equivalency_details).to be_nil
    end
  end

  describe '#before_save' do
    let(:constituent_grades_without_public_ids) { { english_language: { grade: 'A' }, english_literature: { grade: 'B' } } }
    let(:constituent_grades_with_public_ids) { { english_language: { grade: 'C', public_id: 10 }, english_literature: { grade: 'A', public_id: 11 } } }

    describe 'sets the public_id for' do
      it 'a qualification with no constituent_grades' do
        qualification = create(:application_qualification, grade: 'A')

        expect(qualification.constituent_grades).to be_nil
        expect(qualification.public_id).not_to be_nil
      end

      it 'a triple science qualification' do
        qualification = create(
          :application_qualification,
          subject: ApplicationQualification::SCIENCE_TRIPLE_AWARD,
          constituent_grades: { biology: { grade: 'A' }, chemistry: { grade: 'B' }, physics: { grade: 'A*' } },
        )

        expect(qualification.constituent_grades).not_to be_nil
        expect(qualification.public_id).not_to be_nil
      end

      it 'a qualification with constituent_grades' do
        qualification = create(:application_qualification, constituent_grades: constituent_grades_without_public_ids)

        expect(qualification.constituent_grades['english_language']['public_id']).not_to be_nil
        expect(qualification.constituent_grades['english_literature']['public_id']).not_to be_nil
      end
    end

    it 'does not overwrite a public_id if it has already been set at the top level' do
      qualification = create(:application_qualification, public_id: 123)

      qualification.save

      expect(qualification.public_id).to eq(123)
    end

    it 'does not overwrite public_ids if they have already been set in constituent_grades' do
      qualification = create(:application_qualification, constituent_grades: constituent_grades_with_public_ids)

      qualification.save

      expect(qualification.constituent_grades['english_language']['public_id']).to eq(10)
      expect(qualification.constituent_grades['english_literature']['public_id']).to eq(11)
    end

    it 'fills in missing public_ids in constituent_grades' do
      constituent_grades_with_partially_complete_public_ids = constituent_grades_with_public_ids.merge({ 'Cockney Rhyming Slang': { grade: 'A*' } })
      qualification = create(:application_qualification, constituent_grades: constituent_grades_with_partially_complete_public_ids)

      expect(qualification.constituent_grades['english_language']['public_id']).to eq(10)
      expect(qualification.constituent_grades['english_literature']['public_id']).to eq(11)
      expect(qualification.constituent_grades['Cockney Rhyming Slang']['public_id']).not_to be_nil
    end
  end

  describe '#failed_required_gcse?' do
    it 'returns false if the qualification is not GCSE level' do
      expect(build(:degree_qualification).failed_required_gcse?).to be false
    end

    it 'returns false if the qualification is GCSE level but is a non-uk equivalant' do
      expect(build(:gcse_qualification, :non_uk).failed_required_gcse?).to be false
    end

    it 'returns false if the qualification is GCSE and has a pass grade' do
      expect(build(:gcse_qualification, grade: 'B').failed_required_gcse?).to be false
    end

    it 'returns false if the qualification is not for maths, english or science' do
      expect(build(:gcse_qualification, grade: 'E', subject: 'history').failed_required_gcse?).to be false
    end

    it 'returns true if the qualification is GCSE and has a fail grade' do
      expect(build(:gcse_qualification, grade: 'E').failed_required_gcse?).to be true
    end

    it 'returns false if the qualification is GCSE with multiple awards and one is a pass grade' do
      expect(build(:gcse_qualification, :multiple_english_gcses).failed_required_gcse?).to be false
    end

    it 'returns true if the qualification is GCSE with multiple awards and all are fail grades' do
      grades = { english_language: { grade: 'E', public_id: 120282 }, english_literature: { grade: 'D', public_id: 120283 } }
      expect(build(:gcse_qualification, :multiple_english_gcses, constituent_grades: grades).failed_required_gcse?).to be true
    end

    it 'returns false if the qualification is Double Award GCSE and has a numerical pass grade' do
      expect(build(:gcse_qualification, grade: '4-3').failed_required_gcse?).to be false
    end

    it 'returns true if the qualification is Double Award GCSE and has a numerical fail grade' do
      expect(build(:gcse_qualification, grade: '3-3').failed_required_gcse?).to be true
    end
  end
end
