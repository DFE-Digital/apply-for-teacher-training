require 'rails_helper'

# rubocop:disable RSpec/RepeatedExample
RSpec.describe BusinessTime do
  [
    Date.new(2019, 11, 4),
    Date.new(2019, 11, 5),
    Date.new(2019, 11, 6),
    Date.new(2019, 11, 7),
    Date.new(2019, 11, 8),
  ].each do |date|
    it "#{date} is a working day (Monday-Friday)" do
      expect(date.workday?).to eq true
    end
  end

  [
    Date.new(2019, 11, 9),
    Date.new(2019, 11, 10),
  ].each do |date|
    it "#{date} is a non-working (weekend) day" do
      expect(date.workday?).to eq false
    end
  end

  [
    Date.new(2019, 1, 1),
    Date.new(2019, 4, 19),
    Date.new(2019, 4, 22),
    Date.new(2019, 12, 25),
    Date.new(2019, 12, 26),
  ].each do |date|
    it "#{date} is a non-working (bank holiday) day" do
      expect(date.workday?).to eq false
    end
  end
end
# rubocop:enable RSpec/RepeatedExample
