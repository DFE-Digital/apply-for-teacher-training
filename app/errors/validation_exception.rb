class ValidationException < StandardError
  attr_accessor :error_messages

  def initialize(error_messages)
    @error_messages = error_messages
  end

  def as_json
    errors = error_messages.map do |error_message|
      {
        error: 'ValidationError',
        message: error_message,
      }
    end

    { errors: errors }
  end

  def message
    error_messages.join(', ')
  end
end
