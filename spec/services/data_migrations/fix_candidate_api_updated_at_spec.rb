require 'rails_helper'

RSpec.describe DataMigrations::FixCandidateAPIUpdatedAt do
  around do |example|
    Timecop.freeze { example.run }
  end

  it 'does not change valid `candidate_api_updated_at` values' do
    valid_candidate = create(
      :candidate,
    )
    create(
      :application_form,
      candidate: valid_candidate,
      created_at: 3.weeks.ago,
    )
    create(
      :application_form,
      candidate: valid_candidate,
      created_at: 2.weeks.ago,
    )
    valid_candidate.update(candidate_api_updated_at: 5.days.ago)

    expect { described_class.new.change }.not_to(
      change { valid_candidate.reload.candidate_api_updated_at },
    )
  end

  it 'does not change `candidate_api_updated_at` values for candidates with no applications' do
    candidate_with_no_applications = create(:candidate)
    candidate_with_no_applications.update(candidate_api_updated_at: 5.days.ago)

    expect { described_class.new.change }.not_to(
      change { candidate_with_no_applications.reload.candidate_api_updated_at },
    )
  end

  it 'changes invalid `candidate_api_updated_at` values' do
    invalid_candidate = create(
      :candidate,
    )
    create(
      :application_form,
      candidate: invalid_candidate,
      created_at: 3.weeks.ago,
    )
    create(
      :application_form,
      candidate: invalid_candidate,
      created_at: 2.weeks.ago,
    )
    invalid_candidate.update(candidate_api_updated_at: 5.weeks.ago)

    expect { described_class.new.change }.to(
      change { invalid_candidate.reload.candidate_api_updated_at }.to(2.weeks.ago),
    )
  end
end
