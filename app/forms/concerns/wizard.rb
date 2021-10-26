module Wizard
  extend ActiveSupport::Concern

  include ActiveModel::Model

  included do
    attr_accessor :current_step, :action, :referer
    attr_reader :state_store
  end

  module Initializer
    def initialize(state_store, attrs = {})
      @state_store = state_store

      attrs = sanitize_attrs(attrs) if defined?(sanitize_attrs)

      super(last_saved_state.deep_merge(attrs))

      initialize_extra(attrs) if defined?(initialize_extra)
      setup_path_history(attrs) if defined?(setup_path_history)
    end
  end

  def self.included(klass)
    klass.prepend(Initializer)
  end

  def clear_state!
    state_store.delete
  end

  def save_state!
    state_store.write(state)
  end

  def valid_for_current_step?
    valid?(current_step.to_sym)
  end

private

  def last_saved_state
    saved_state = state_store.read
    saved_state ? JSON.parse(saved_state).with_indifferent_access : {}
  end

  def state
    as_json(except: state_excluded_attributes).to_json
  end

  def state_excluded_attributes
    %w[state_store errors validation_context]
  end
end
