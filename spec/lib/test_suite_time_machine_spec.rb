require 'rails_helper'

RSpec.describe TestSuiteTimeMachine do
  around do |example|
    described_class.revert_to_real_world_time
    @real_world_time = Time.zone.now
    example.run
    described_class.revert_to_real_world_time
    described_class.pretend_it_is(ENV.fetch('TEST_DATE_AND_TIME', 'real_world'))
  end

  before do
    allow(Timecop).to receive(:freeze).and_call_original
    allow(Timecop).to receive(:travel).and_call_original
  end

  describe '.pretend_it_is(date_and_time)' do
    subject(:travel_to) { described_class.pretend_it_is(date_and_time) }

    let(:date_and_time) { nil }

    context 'when the argument is blank' do
      let(:date_and_time) { ' ' }

      it 'travels to the current time' do
        expect { travel_to }
          .to change { Time.zone.now }
          .to be_within(1.second).of(Time.zone.now)
      end
    end

    context 'when the argument is "real_world"' do
      let(:date_and_time) { 'real_world' }

      it 'travels to the current time' do
        expect { travel_to }
          .to change { Time.zone.now }
          .to be_within(1.second).of(Time.zone.now)
      end
    end

    context 'when the argument is a date and time' do
      let(:date_and_time) { '2020-01-01 12:00:00' }

      it 'travels to the given date and time' do
        expect { travel_to }
          .to change { Time.zone.now }
          .to be_within(1.second).of(DateTime.new(2020, 1, 1, 12, 0))
      end
    end

    context 'when the argument is an ISO 8601 date and time' do
      let(:date_and_time) { '2020-01-01T12:00:00' }

      it 'travels to the given date and time' do
        expect { travel_to }
          .to change { Time.zone.now }
          .to be_within(1.second).of(DateTime.new(2020, 1, 1, 12, 0))
      end
    end

    context 'when the argument is a date offset' do
      let(:date_and_time) { '5.days.from_now' }

      it 'travels to the given date and time' do
        expect { travel_to }
          .to change { Time.zone.now }
          .to be_within(1.second).of(5.days.from_now)
      end
    end

    it 'freezes time' do
      travel_to
      expect { sleep 1 }.not_to(change { Time.zone.now })
    end
  end

  describe '.travel_temporarily_to(date_and_time, freeze: true, &block)' do
    it 'freezes time by default' do
      described_class.travel_temporarily_to('2020-01-01 12:00:00') { nil }
      expect(Timecop).to have_received(:freeze)
      expect(Timecop).not_to have_received(:travel)
    end

    it 'travels to the given date and time, during the block' do
      before_time = Time.zone.now
      described_class.travel_temporarily_to('2020-01-01 12:00:00') do
        expect(Time.zone.now).to be_within(1.second).of(DateTime.new(2020, 1, 1, 12, 0))
      end
      expect(Time.zone.now).to be_within(1.second).of(before_time)
    end

    it "doesn't freeze time when freeze: false" do
      described_class.travel_temporarily_to('2020-01-01 12:00:00', freeze: false) { nil }
      expect(Timecop).not_to have_received(:freeze)
      expect(Timecop).to have_received(:travel)
    end

    it 'errors if a block is not given' do
      expect { described_class.travel_temporarily_to('2020-01-01 12:00:00') }
        .to raise_error(described_class::TimeTravelError)
    end
  end

  describe '.travel_permanently_to(date_and_time, freeze: true)' do
    before do
      Timecop.safe_mode = false
    end

    it 'freezes time by default' do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      expect(Timecop).to have_received(:freeze)
      expect(Timecop).not_to have_received(:travel)
    end

    it 'travels to the given date and time' do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      expect(Time.zone.now).to be_within(1.second).of(DateTime.new(2020, 1, 1, 12, 0))
    end

    it "doesn't freeze time when freeze: false" do
      described_class.travel_permanently_to('2020-01-01 12:00:00', freeze: false)
      expect(Timecop).not_to have_received(:freeze)
      expect(Timecop).to have_received(:travel)
    end
  end

  describe '.advance_time_to(date_and_time)' do
    before do
      Timecop.safe_mode = false
    end

    it 'advances time to the given date and time' do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      described_class.advance_time_to('2020-01-02 12:00:00')
      expect(Time.zone.now).to be_within(1.second).of(DateTime.new(2020, 1, 2, 12, 0))
    end

    it "doesn't allow time to go backwards" do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      described_class.advance_time_to('2020-01-02 12:00:00')
      expect { described_class.advance_time_to('2020-01-01 12:00:00') }
        .to raise_error(described_class::TimeTravelError)
    end
  end

  describe '.advance_time_by(duration)' do
    before do
      Timecop.safe_mode = false
    end

    it 'advances time by the given duration' do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      described_class.advance_time_by(1.day)
      expect(Time.zone.now).to be_within(1.second).of(DateTime.new(2020, 1, 2, 12, 0))
    end

    it "doesn't allow time to go backwards" do
      described_class.travel_permanently_to('2020-01-01 12:00:00')
      expect { described_class.advance_time_by(-1.day) }
        .to raise_error(described_class::TimeTravelError)
    end
  end

  describe '.advance' do
    before do
      Timecop.safe_mode = false
    end

    it 'advances time by 1 second' do
      before_time = Time.zone.now
      described_class.advance
      expect(Time.zone.now).to be_within(0.1.seconds).of(before_time + 1.second)
    end
  end

  describe '.revert_to_real_world_time' do
    it 'resets the time to the real world time' do
      expect { described_class.revert_to_real_world_time }
        .to change { Time.zone.now }
        .to be_within(1.second).of(@real_world_time)
    end

    it 'restores Timecop safe_mode' do
      Timecop.safe_mode = false
      described_class.revert_to_real_world_time
      expect(Timecop.safe_mode?).to be(true)
    end
  end

  describe '.reset' do
    context 'if a baseline has not been set' do
      it 'raises an error' do
        expect { described_class.reset }
          .to raise_error(described_class::TimeTravelError)
      end
    end

    context 'if a baseline has been set' do
      before do
        described_class.pretend_it_is('2020-01-01 12:00:00')
      end

      it 'resets the time to the baseline' do
        described_class.travel_permanently_to('2020-01-02 12:00:00')

        expect { described_class.reset }
          .to change { Time.zone.now }
          .to be_within(1.second).of(DateTime.new(2020, 1, 1, 12, 0))
      end

      it 'freezes time' do
        described_class.reset
        expect { sleep 1 }.not_to(change { Time.zone.now })
      end
    end
  end
end
