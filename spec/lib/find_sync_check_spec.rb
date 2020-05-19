require 'rails_helper'

RSpec.describe FindSyncCheck do
  describe '#check' do
    it 'succeeds if the sync has happened in the last hour' do
      FindSyncCheck.set_last_sync(Time.zone.now)

      expect(FindSyncCheck.new.check).to eql('The sync with Find has succeeded in the last hour')
    end

    it 'fails if the sync has never happened' do
      FindSyncCheck.clear_last_sync

      expect(FindSyncCheck.new.check).to eql('Problem finding the time when the Find sync last succeeded')
    end

    it 'fails if the sync hasn\'t happened recently' do
      FindSyncCheck.set_last_sync(Time.zone.now - 10.days)

      expect(FindSyncCheck.new.check).to eql('The sync with Find hasn\'t succeeded in an hour')
    end
  end
end
