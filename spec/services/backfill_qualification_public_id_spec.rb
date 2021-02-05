require 'rails_helper'

RSpec.describe BackfillQualificationPublicId do
  describe '#call' do
    context 'unstructured qualifications' do
      let(:qualification_with_no_public_id) do
        qualification = create(:application_qualification, grade: 'A')
        qualification.update_columns(public_id: nil)
        qualification
      end

      it 'copies the database id into the public_id column' do
        described_class.new(qualification_with_no_public_id).call

        expect(qualification_with_no_public_id.public_id).to eq(qualification_with_no_public_id.id)
      end

      it 'is idempotent' do
        described_class.new(qualification_with_no_public_id).call

        expect {
          described_class.new(qualification_with_no_public_id).call
        }.not_to(change { qualification_with_no_public_id.public_id })
      end

      it 'has no effect on qualifications with a public_id' do
        qualification = create(:application_qualification, public_id: 123)

        expect {
          described_class.new(qualification).call
        }.not_to(change { qualification.public_id })
      end
    end

    context 'structured qualifications' do
      let(:qualification_without_public_id) do
        qualification = create(:application_qualification)
        qualification.update_columns(
          public_id: nil,
          constituent_grades: {
            english_language: { grade: 'A' },
            english_literature: { grade: 'B' },
          },
        )
        qualification
      end

      it 'copies the database id into the first constituent_grade' do
        described_class.new(qualification_without_public_id).call

        expect(qualification_without_public_id.public_id).to be_nil
        expect(qualification_without_public_id.constituent_grades['english_language']['public_id']).to eq(qualification_without_public_id.id)
        expect(qualification_without_public_id.constituent_grades['english_literature']['public_id']).not_to be_nil
      end

      it 'is idempotent' do
        described_class.new(qualification_without_public_id).call

        expect {
          described_class.new(qualification_without_public_id).call
        }.not_to(change { qualification_without_public_id.constituent_grades['english_language']['public_id'] })

        expect {
          described_class.new(qualification_without_public_id).call
        }.not_to(change { qualification_without_public_id.constituent_grades['english_literature']['public_id'] })
      end

      it 'has no effect on qualifications with the public_ids set' do
        qualification = create(:application_qualification, constituent_grades: { english_language: { grade: 'A', public_id: 88 }, english_literature: { grade: 'B', public_id: 89 } })

        described_class.new(qualification).call

        expect(qualification.constituent_grades['english_language']['public_id']).to eq(88)
        expect(qualification.constituent_grades['english_literature']['public_id']).to eq(89)
      end
    end
  end
end
