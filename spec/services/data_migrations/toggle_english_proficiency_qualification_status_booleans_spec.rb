require 'rails_helper'

RSpec.describe DataMigrations::ToggleEnglishProficiencyQualificationStatusBooleans do
  subject(:data_migration) { described_class.new.change }

  let(:has_qualifications) do
    create_list(
      :english_proficiency,
      3,
      qualification_status: 'has_qualification',
      has_qualification: false,
      qualification_not_needed: false,
      no_qualification: false,
    )
  end
  let(:no_qualifications) do
    create_list(
      :english_proficiency,
      3,
      qualification_status: 'no_qualification',
      no_qualification: false,
      has_qualification: false,
      qualification_not_needed: false,
    )
  end
  let(:qualifications_not_needed) do
    create_list(
      :english_proficiency,
      3,
      qualification_status: 'qualification_not_needed',
      no_qualification: false,
      has_qualification: false,
      qualification_not_needed: false,
    )
  end

  before do
    has_qualifications
    no_qualifications
    qualifications_not_needed
  end

  it 'updates english proficiencies with the correct booleans qualification statuses' do
    data_migration

    has_qualifications.each do |has_qualification_proficiency|
      has_qualification_proficiency.reload
      expect(has_qualification_proficiency.has_qualification).to eq(true)

      expect(has_qualification_proficiency.no_qualification).to eq(false)
      expect(has_qualification_proficiency.qualification_not_needed).to eq(false)
    end

    no_qualifications.each do |no_qualification_proficiency|
      no_qualification_proficiency.reload
      expect(no_qualification_proficiency.no_qualification).to eq(true)

      expect(no_qualification_proficiency.has_qualification).to eq(false)
      expect(no_qualification_proficiency.qualification_not_needed).to eq(false)
    end

    qualifications_not_needed.each do |qualifications_not_needed_proficiency|
      qualifications_not_needed_proficiency.reload
      expect(qualifications_not_needed_proficiency.qualification_not_needed).to eq(true)

      expect(qualifications_not_needed_proficiency.has_qualification).to eq(false)
      expect(qualifications_not_needed_proficiency.no_qualification).to eq(false)
    end
  end
end
