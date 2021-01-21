module Wizard
  extend ActiveSupport::Concern

  included do
    attr_writer :state_store
    attr_accessor :current_step, :review_mode
  end

  def initialize(state_store, params = {})
    @state_store = state_store
    sanitize_attributes!(params)

    super(last_saved_state.deep_merge(params))

    enter_review_mode! if current_step.eql?('check')
  end

  # placeholder for multiple step wizards
  def next_step; end

  # placeholder for multiple step wizards
  def previous_step; end

  def clear_state!
    @state_store.delete
  end

  def save_state!
    @state_store.write(state)
  end

  def valid?
    current_step.present? ? super(current_step.to_sym) : super
  end

private

  def state
    as_json(except: params_to_exclude_from_saved_state).to_json
  end

  def last_saved_state
    saved_state = @state_store.read
    saved_state ? JSON.parse(saved_state) : {}
  end

  def params_to_exclude_from_saved_state
    %w[state_store errors validation_context current_step]
  end

  # placeholder to enable sanitizing of input parameters if required
  def sanitize_attributes!(params); end

  def enter_review_mode!
    @review_mode = true
  end
end
