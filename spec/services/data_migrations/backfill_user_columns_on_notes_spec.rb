require 'rails_helper'

RSpec.describe DataMigrations::BackfillUserColumnsOnNotes do
  it 'backfills polymorphic User columns' do
    provider_user = create(:provider_user)
    vendor_api_user = create(:vendor_api_user)
    note = create(:note, user: provider_user)
    another_note = create(:note, user: vendor_api_user)

    described_class.new.change

    expect(note.user_id).to eq(provider_user.id)
    expect(note.user_type).to eq('ProviderUser')

    expect(another_note.user).to eq(vendor_api_user)
  end
end
