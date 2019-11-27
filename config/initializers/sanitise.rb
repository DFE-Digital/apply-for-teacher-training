# Make `sanitize` strip all tags by default
#
# https://apidock.com/rails/ActionView/Helpers/SanitizeHelper/sanitize
# Used by https://apidock.com/rails/ActionView/Helpers/TextHelper/simple_format
ActionView::Base.sanitized_allowed_tags = %w[]
