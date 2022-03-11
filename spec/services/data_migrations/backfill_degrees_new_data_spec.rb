require 'rails_helper'

RSpec.describe DataMigrations::BackfillDegreesNewData do
  let(:bachelor_of_arts) do
    DfE::ReferenceData::Degrees::TYPES.some(abbreviation: 'BA').first
  end
  let(:falmouth_university) do
    DfE::ReferenceData::Degrees::INSTITUTIONS.some(name: 'Falmouth University').first
  end
  let(:royal_academy_of_music) do
    DfE::ReferenceData::Degrees::INSTITUTIONS.some(name: 'Royal Academy of Music').first
  end
  let(:animation) do
    DfE::ReferenceData::Degrees::SUBJECTS.some(name: 'Animation').first
  end
  let(:first_class_honours) do
    DfE::ReferenceData::Degrees::GRADES.some(name: 'First-class honours').first
  end
  let(:unclassified) do
    DfE::ReferenceData::Degrees::GRADES.some(name: 'Unclassified').first
  end

  context 'when degrees exists in the new data' do
    it 'updates degrees UUIDs' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'BA',
        qualification_type_hesa_code: nil,
        subject: 'Animation',
        subject_hesa_code: nil,
        institution_name: 'Falmouth University',
        institution_hesa_code: nil,
        grade: 'Unclassified',
        grade_hesa_code: nil,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'degree_type_uuid' => bachelor_of_arts.id,
          'degree_institution_uuid' => falmouth_university.id,
          'degree_subject_uuid' => animation.id,
          'degree_grade_uuid' => unclassified.id,
        },
      )
    end
  end

  context 'when degrees exists in the hesa codes' do
    let(:degree_qualification) do
      create(
        :degree_qualification,
        qualification_type: 'BA',
        subject: 'Animation',
        institution_name: 'Falmouth University',
        grade: 'Unclassified',
      )
    end

    before do
      degree_qualification.update_columns(
        qualification_type_hesa_code: '51',
        subject_hesa_code: '100057',
        institution_hesa_code: '17',
        grade_hesa_code: '7',
      )
    end

    it 'updates degrees UUIDs' do
      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'degree_type_uuid' => bachelor_of_arts.id,
          'degree_institution_uuid' => falmouth_university.id,
          'degree_subject_uuid' => animation.id,
          'degree_grade_uuid' => unclassified.id,
        },
      )
    end
  end

  context 'when only some degrees exists in the new data' do
    it 'updates degrees UUIDs' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'BA',
        subject: 'Animation',
        institution_name: 'My super University',
        grade: 'A grade that does not exist',
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'degree_type_uuid' => bachelor_of_arts.id,
          'degree_institution_uuid' => nil,
          'degree_subject_uuid' => animation.id,
          'degree_grade_uuid' => nil,
        },
      )
    end
  end

  context 'when institution and grade both match a match synonym' do
    it 'updates degrees UUIDs' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'Some qualification',
        subject: 'Some subject',
        institution_name: 'The Royal Academy of Music',
        grade: 'First class honours',
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'degree_type_uuid' => nil,
          'degree_institution_uuid' => royal_academy_of_music.id,
          'degree_subject_uuid' => nil,
          'degree_grade_uuid' => first_class_honours.id,
        },
      )
    end
  end

  context 'when degrees types is saved by name' do
    it 'updates degrees UUIDs' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'degree_type_uuid' => bachelor_of_arts.id,
        },
      )
    end
  end

  context 'does not update timestamps' do
    let(:timestamp) { Time.zone.local(2021, 6, 27, 12, 10, 10) }

    it 'does not touch timestamps' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        created_at: timestamp,
        updated_at: timestamp,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'created_at' => timestamp,
          'updated_at' => timestamp,
        },
      )
    end
  end
end
