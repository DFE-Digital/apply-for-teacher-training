require 'eventmachine'

Thread.new do
  # EventMachine.run is a event loop
  EventMachine.run do
    puts 'Starting EventMachine...'
  end
end
