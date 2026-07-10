require 'rails_helper'

RSpec.describe DataMigrations::ResolveDuplicateMatchesUnsubmitted2025OrBefore2025 do
  it 'resolves only if unsubmitted in 2025' do
    to_resolve_duplicate_match = create(:duplicate_match, resolved: false)

    create(
      :application_form,
      candidate: to_resolve_duplicate_match.candidates.first,
      recruitment_cycle_year: 2025,
      submitted_at: nil,
    )

    not_to_resolve_duplicate_match = create(:duplicate_match, resolved: false)

    create(
      :application_form,
      candidate: not_to_resolve_duplicate_match.candidates.first,
      recruitment_cycle_year: 2025,
      submitted_at: Time.zone.now,
    )

    described_class.new.change

    expect(not_to_resolve_duplicate_match.reload.resolved?).to be(false)
    expect(to_resolve_duplicate_match.reload.resolved?).to be(true)
  end

  it 'resolves if all applications forms are before 2025' do
    to_resolve_duplicate_match = create(:duplicate_match, resolved: false)
    create(
      :application_form,
      candidate: to_resolve_duplicate_match.candidates.first,
      recruitment_cycle_year: 2024,
      submitted_at: Time.zone.now,
    )

    not_to_resolve_duplicate_match = create(:duplicate_match, resolved: false)

    create(
      :application_form,
      candidate: not_to_resolve_duplicate_match.candidates.first,
      recruitment_cycle_year: 2024,
      submitted_at: Time.zone.now,
    )

    create(
      :application_form,
      candidate: not_to_resolve_duplicate_match.candidates.first,
      recruitment_cycle_year: 2026,
      submitted_at: Time.zone.now,
    )

    described_class.new.change

    expect(not_to_resolve_duplicate_match.reload.resolved?).to be(false)
    expect(to_resolve_duplicate_match.reload.resolved?).to be(true)
  end
end
