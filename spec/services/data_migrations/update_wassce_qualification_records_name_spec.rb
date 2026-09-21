require 'rails_helper'

RSpec.describe DataMigrations::UpdateWassceQualificationRecordsName do
  it 'updates the non_uk_qualification_type of WASSCE application qualifications' do
    wassce_qualification = create(:application_qualification, non_uk_qualification_type: 'WASSCE (West African Senior School Certificate Examination)')
    non_wassce_qualification = create(:application_qualification)

    described_class.new.change

    expect(
      wassce_qualification.reload.non_uk_qualification_type,
    ).to eq('WAEC, WASSCE (West African Senior School Certificate Examination)')
    expect(
      non_wassce_qualification.reload.non_uk_qualification_type,
    ).to be_nil
  end
end
