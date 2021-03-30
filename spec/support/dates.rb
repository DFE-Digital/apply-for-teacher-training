
RSpec.configure do |config|
  config.around do |example|
    Timecop.travel(Time.zone.local(2021, 8, 24, 12, 0, 0)) do
      example.run
    end
  end
end
