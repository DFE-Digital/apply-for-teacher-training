RSpec::Matchers.define :have_error_on do |attribute|
  match do |actual|
    actual.valid?
    actual.errors.messages[attribute].any?
  end

  failure_message do |_actual|
    "expected `#{attribute}` to have an error"
  end

  failure_message_when_negated do |_actual|
    "expected `#{attribute}` to not have an error"
  end
end
