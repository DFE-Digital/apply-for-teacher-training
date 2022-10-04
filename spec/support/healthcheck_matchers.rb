# From https://github.com/sportngin/okcomputer/blob/d847ecbfb8ae9a56a58a392aa7dede07b29ce3c1/spec/support/check_matcher.rb

RSpec::Matchers.define :have_message do |message|
  match do |actual|
    actual.check
    actual.message.include?(message)
  end

  failure_message do |actual|
    "expected '#{actual.message}' to include '#{message}'"
  end

  failure_message_when_negated do |actual|
    "expected '#{actual.message}' to not include '#{message}'"
  end
end

RSpec::Matchers.define :be_successful_check do
  match do |actual|
    actual.check
    actual.success?
  end

  failure_message do |actual|
    "expected #{actual.inspect} to be successful"
  end

  failure_message_when_negated do |actual|
    "expected '#{actual}' to not be successful"
  end
end
