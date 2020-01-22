RSpec.configure do |config|
  config.around sandbox: true do |example|
    ClimateControl.modify(SANDBOX: 'true') do
      example.run
    end
  end

  config.around sandbox: false do |example|
    ClimateControl.modify(SANDBOX: 'false') do
      example.run
    end
  end
end
