Audited.auditing_enabled = false

RSpec.configure do |config|
  config.around(:each, with_audited: true) do |example|
    Audited.auditing_enabled = true
    example.run
    Audited.auditing_enabled = false
  end
end
