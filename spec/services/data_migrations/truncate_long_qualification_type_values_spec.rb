require 'rails_helper'

RSpec.describe DataMigrations::TruncateLongQualificationTypeValues do
  let(:qualification) { create(:application_qualification) }
  let(:long_value) { SecureRandom.alphanumeric(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH + 1) }
  let(:valid_value) { SecureRandom.alphanumeric(ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH) }

  it 'truncates `qualification_type` values that are too long' do
    qualification.update_column(:qualification_type, long_value)

    expect { described_class.new.change }.to change { qualification.reload.qualification_type.length }.by(-1)
  end

  it 'truncates `non_uk_qualification_type` values that are too long' do
    qualification.update_column(:non_uk_qualification_type, long_value)

    expect { described_class.new.change }.to change { qualification.reload.non_uk_qualification_type.length }.by(-1)
  end

  it 'leaves valid `qualification_type` and `non_uk_qualification_type` values alone' do
    qualification.update_column(:qualification_type, valid_value)
    qualification.update_column(:non_uk_qualification_type, valid_value)

    described_class.new.change

    expect(qualification.reload.qualification_type).to eq(valid_value)
    expect(qualification.non_uk_qualification_type).to eq(valid_value)
  end
end
