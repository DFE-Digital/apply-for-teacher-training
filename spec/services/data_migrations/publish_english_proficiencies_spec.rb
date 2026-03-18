require 'rails_helper'

RSpec.describe DataMigrations::PublishEnglishProficiencies do
  subject(:data_migration) { described_class.new.change }

  let(:english_proficiencies) { create_list(:english_proficiency, 5, draft: true) }

  before { english_proficiencies }

  it 'updates the draft state of all existing english proficiencies' do
    data_migration
    expect(
      EnglishProficiency.where(id: english_proficiencies.pluck(:id)).pluck(:draft).uniq,
    ).to contain_exactly(false)
  end
end
