require 'rails_helper'

RSpec.describe DataMigrations::ResolveMistakenlyUnresolvedDuplicates do
  it 'only resolves duplicates updated in the window' do
    too_early_duplicate = create(:duplicate_match, resolved: false, updated_at: Time.zone.local(2026, 7, 9, 15, 20))
    too_late_duplicate = create(:duplicate_match, resolved: false, updated_at: Time.zone.local(2026, 7, 9, 16, 22))
    just_right_duplicate = create(:duplicate_match, resolved: false, updated_at: Time.zone.local(2026, 7, 9, 16, 0o0))

    described_class.new.change

    expect(too_early_duplicate.reload.resolved).to be(false)
    expect(too_late_duplicate.reload.resolved).to be(false)
    expect(just_right_duplicate.reload.resolved).to be(true)
  end
end
