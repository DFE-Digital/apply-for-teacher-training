RSpec::Matchers.define :have_metrics_tracked do |trackable, key, user, event|
  supports_block_expectations

  match do |block|
    tracker = instance_double(Metrics::Tracker, track: nil)
    allow(Metrics::Tracker).to receive(:new).and_return(tracker)
    block.call
    expect(Metrics::Tracker).to have_received(:new).with(trackable, key, user)
    expect(tracker).to have_received(:track).with(event)
  end
end

RSpec::Matchers.define :have_metrics_tracked_with_interval do |trackable, key, user, interval, event|
  supports_block_expectations

  match do |block|
    tracker = instance_double(Metrics::Tracker, track: nil)
    allow(Metrics::Tracker).to receive(:new).and_return(tracker)
    block.call
    expect(Metrics::Tracker).to have_received(:new).with(trackable, key, user)
    expect(tracker).to have_received(:track).with(event, interval)
  end
end
