require 'rails_helper'

RSpec.describe Metrics do
  let(:user) { create(:provider_user) }
  let(:course) { create(:course) }

  describe Metrics::Tracker do
    describe '#track' do
      it 'tracks information for the provided event' do
        metrics = Metrics::Tracker.new(course, 'notifications.on', user)
        metrics.track(:tracked_event)

        last_metrics = PublicActivity::Activity.last
        expect(last_metrics.owner).to eq(user)
        expect(last_metrics.trackable).to eq(course)
        expect(last_metrics.parameters).to eq(event: :tracked_event)
      end
    end
  end

  describe Metrics::Data do
    before do
      Metrics::Tracker.new(course, 'notifications.on', user).track(:course_updated)
      Metrics::Tracker.new(course, 'notifications.off', user).track(:course_updated)
      Metrics::Tracker.new(course, 'notifications.off', create(:provider_user)).track(:course_updated)
    end

    describe '#for' do
      it 'retrieves data for a provided key' do
        data = Metrics::Data.new(user).for('notifications.on')

        expect(data.count).to eq(1)
      end

      it 'retrieves data for a provided event' do
        data = Metrics::Data.new(user).for(nil, :course_updated)

        expect(data.count).to eq(2)
      end

      it 'retrieves data for a key/event combination' do
        data = Metrics::Data.new(user).for('notifications.off', :course_updated)

        expect(data.count).to eq(1)
      end
    end
  end

  describe Metrics::IntervalToSeconds do
    describe '#call' do
      it 'converts an interval to seconds' do
        seconds = Metrics::IntervalToSeconds.new('336:30:20').call

        expect(seconds).to eq(1211420)
      end
    end
  end
end
