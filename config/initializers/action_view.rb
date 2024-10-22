Rails.application.configure do
  config.action_view.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder
  config.action_view.form_with_generates_remote_forms = false

  # Make `sanitize` strip all tags by default
  # https://guides.rubyonrails.org/action_view_helpers.html#sanitizehelper
  config.action_view.sanitized_allowed_tags = %w[]
end
