module ActiveRecord::Enum
  # Enums in Rails are also added as a negative. For example, a "cancelled" enum
  # type will have a "not_cancelled" scope.
  #
  #   https://github.com/rails/rails/blob/1eade80dd69495cb98bcb03448a358107013dd61/activerecord/lib/active_record/enum.rb#L30-L36
  #
  # This works a bit weird with scopes that are already negative, like we have
  # for ApplicationReference#not_requested_yet. If we were to add an enum called
  # "requested_yet", both a scope "not_requested_yet" (positive) and
  # "not_requested_yet" (negative of "requested_yet") would be generated.
  #
  # To prevent this Rails already raises an error if it actually occurs:
  #
  #   https://github.com/rails/rails/blob/1eade80dd69495cb98bcb03448a358107013dd61/activerecord/lib/active_record/enum.rb#L255-L265
  #
  # Rails also logs a warning, even if there's no actual conflict yet. This is a
  # bit annoying because we're pretty sure what we're doing with the "not_requested_yet"
  # enum. This monkey patch removes the warning log.
  #
  # https://github.com/rails/rails/blob/1eade80dd69495cb98bcb03448a358107013dd61/activerecord/lib/active_record/enum.rb#L255-L265
  #
  # There's a Rails issue from April 2020 that deals with this thing: https://github.com/rails/rails/issues/39065
  def detect_negative_condition!(method_name); end
end
