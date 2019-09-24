class Timeframe < ApplicationRecord
  def self.applicable_at(time)
    where('? >= from_time and ? < to_time', time, time).first
  end
end
