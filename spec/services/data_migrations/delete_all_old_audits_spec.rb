require 'rails_helper'

RSpec.describe DataMigrations::DeleteAllOldAudits do
  describe '#change' do
    it 'enqueues the DeleteAllAuditsInBatches worker' do
      expect { described_class.new.change }.to enqueue_job(DeleteAllOldAuditsInBatches)
    end
  end
end
