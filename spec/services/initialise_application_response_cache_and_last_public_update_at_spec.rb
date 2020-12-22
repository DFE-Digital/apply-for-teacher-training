require 'rails_helper'

RSpec.describe InitialiseApplicationResponseCacheAndLastPublicUpdateAt do
  it 'does not change applications which already have last_public_update_at set' do
    application_choice = create(:application_choice, :awaiting_provider_decision)
    application_choice.update_columns(:last_public_update_at, Time.zone.local(2020, 1, 1, 9))

    expect(application_choice.application_response_cache).to be_empty

    expect { InitialiseApplicationResponseCacheAndLastPublicUpdateAt.call }
      .not_to(change { application_choice.reload.last_public_update_at })
  end

  it 'assigns updated_at to last_public_update_at' do
    application_choice = create(:application_choice, :awaiting_provider_decision)

    # when we run this no applications will have a last_public_update_at
    # or a cache set, so remove them
    application_choice.update_column(:last_public_update_at, nil)
    application_choice.application_response_cache.destroy

    expect { InitialiseApplicationResponseCacheAndLastPublicUpdateAt.call }
      .to(change { application_choice.reload.last_public_update_at })

    expect(application_choice.application_response_cache.reload.response).to be_present
  end
end
