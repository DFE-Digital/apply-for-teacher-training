require 'rails_helper'

RSpec.describe DataMigrations::BackfillQualificationLevel do
  context 'when bachelor' do
    let(:bachelor_of_arts) do
      DfE::ReferenceData::Degrees::TYPES.some(abbreviation: 'BA').first
    end
    let(:bachelor) do
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: 'bachelors degree').first
    end

    it 'saves qualification level and qualification level UUID' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: bachelor_of_arts.name,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => 'bachelor',
          'qualification_level_uuid' => bachelor.id,
        },
      )
    end
  end

  context 'when master' do
    let(:master_of_arts) do
      DfE::ReferenceData::Degrees::TYPES.some(abbreviation: 'MA').first
    end
    let(:master) do
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: "master's degree").first
    end

    it 'saves qualification level and qualification level UUID' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: master_of_arts.name,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => 'master',
          'qualification_level_uuid' => master.id,
        },
      )
    end
  end

  context 'when doctor' do
    let(:doctor_of_music) do
      DfE::ReferenceData::Degrees::TYPES.some(abbreviation: 'DMu').first
    end
    let(:doctor) do
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: 'doctorate').first
    end

    it 'saves qualification level and qualification level UUID' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: doctor_of_music.name,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => 'doctor',
          'qualification_level_uuid' => doctor.id,
        },
      )
    end
  end

  context 'when foundation' do
    let(:foundation_of_sciences) do
      DfE::ReferenceData::Degrees::TYPES.some(abbreviation: 'FdSs').first
    end
    let(:foundation) do
      DfE::ReferenceData::Qualifications::QUALIFICATIONS.some(name: 'foundation degree').first
    end

    it 'saves qualification level and qualification level UUID' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: foundation_of_sciences.name,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => 'foundation',
          'qualification_level_uuid' => foundation.id,
        },
      )
    end
  end

  context 'when degree is nil' do
    it 'does not save any qualification level' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: nil,
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => nil,
          'qualification_level_uuid' => nil,
        },
      )
    end
  end

  context 'when degree is not found in the data' do
    it 'does not save any qualification level' do
      degree_qualification = create(
        :degree_qualification,
        qualification_type: 'My awesome degree',
      )

      described_class.new.change

      expect(degree_qualification.reload.attributes).to include(
        {
          'qualification_level' => nil,
          'qualification_level_uuid' => nil,
        },
      )
    end
  end
end
