Audited.auditing_enabled = false
AUDIT_USER_NAME = '(Automated process)'.freeze

RSpec.configure do |config|
  config.around(:each, :with_audited) do |example|
    Audited.auditing_enabled = true

    if example.metadata.keys.include?(:audited_automatic_process)
      Audited.audit_class.as_user(AUDIT_USER_NAME) do
        example.run
      end
    else
      example.run
    end

    Audited.auditing_enabled = false
  end
end
