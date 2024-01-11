require 'rails_helper'

RSpec.describe DataMigrations::SetInstitutionCountryToGbOnUkDegrees do
  let(:degree_qualification) { create(:degree_qualification, institution_country:, international:) }

  context 'when institution_country is nil and international is false' do
    let(:institution_country) { nil }
    let(:international) { false }

    it 'updates the application qualifications' do
      expect { described_class.new.change }.to(
        change { degree_qualification.reload.institution_country }
          .from(nil)
          .to('GB'),
      )
    end
  end

  context 'when institution_country is nil and international is true' do
    let(:institution_country) { nil }
    let(:international) { true }

    it 'does not update the application qualification' do
      expect { described_class.new.change }.not_to(
        change { degree_qualification.reload.institution_country },
      )
    end
  end

  context 'when institution_country is an empty string and international is false' do
    let(:institution_country) { ' ' }
    let(:international) { false }

    it 'does not update the application qualification' do
      expect { described_class.new.change }.not_to(
        change { degree_qualification.reload.institution_country },
      )
    end
  end

  context 'when institution_country is abu dhabi' do
    let(:institution_country) { 'AE-AZ' }
    let(:international) { false }

    it 'does not update the application qualification' do
      expect { described_class.new.change }.not_to(
        change { degree_qualification.reload.institution_country },
      )
    end
  end

  context 'when as level qualification and institution country is nil and international is false' do
    let(:as_qualification) { create(:as_level_qualification, institution_country:, international:) }
    let(:institution_country) { nil }
    let(:international) { false }

    it 'does not update the application qualification' do
      expect { described_class.new.change }.not_to(
        change { as_qualification.reload.institution_country },
      )
    end
  end
end
