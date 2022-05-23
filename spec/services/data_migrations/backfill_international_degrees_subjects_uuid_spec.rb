require 'rails_helper'

RSpec.describe DataMigrations::BackfillInternationalDegreesSubjectsUuid do
  let(:animation) do
    DfE::ReferenceData::Degrees::SUBJECTS.some(name: 'Animation').first
  end

  context 'when international' do
    context 'when created after new degree flow' do
      it 'saves the subject UUID' do
        degree_qualification = create(
          :non_uk_degree_qualification,
          subject: 'Animation',
          created_at: DateTime.new(2022, 5, 4, 14),
        )

        described_class.new.change

        expect(degree_qualification.reload.degree_subject_uuid).to eq(animation.id)
      end
    end

    context 'when subject is not in the reference data' do
      it 'does not change the subject UUID' do
        degree_qualification = create(
          :non_uk_degree_qualification,
          subject: 'Animatron',
          created_at: DateTime.new(2022, 5, 4, 14),
        )

        described_class.new.change

        expect(degree_qualification.reload.degree_subject_uuid).to be_nil
      end
    end

    context 'when created before new degree flow' do
      it 'does not change the subject UUID' do
        degree_qualification = create(
          :degree_qualification,
          subject: 'Animation',
          institution_country: 'BR',
          created_at: DateTime.new(2022, 5, 4, 13),
        )

        described_class.new.change

        expect(degree_qualification.reload.degree_subject_uuid).to be_nil
      end
    end
  end

  context 'when degree is from UK' do
    it 'does not change the subject UUID' do
      degree_qualification = create(
        :degree_qualification,
        subject: 'Animation',
        institution_country: nil,
        created_at: DateTime.new(2022, 5, 4, 14),
      )

      described_class.new.change

      expect(degree_qualification.reload.degree_subject_uuid).to be_nil
    end
  end
end
