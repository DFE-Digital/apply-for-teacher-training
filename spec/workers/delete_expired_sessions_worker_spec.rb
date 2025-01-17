require 'rails_helper'

RSpec.describe DeleteExpiredSessionsWorker do
  describe '#perform' do
    it 'deletes sessions that have not been updated in over 7 days' do
      should_delete = create(:session)
      should_not_delete = create(:session)

      advance_time_to 3.5.days.from_now
      should_not_delete.touch
      advance_time_to 4.days.from_now

      expect { described_class.new.perform }.to change { Session.count }.by(-1)
      expect { should_delete.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
