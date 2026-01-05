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
      attrs = sanitize_attrs(attrs)
      state = sanitize_last_saved_state(last_saved_state, attrs)
      super(state.deep_merge(attrs).select { |attr| self.class.method_defined?(:"#{attr}=") })

      initialize_extra(attrs)
      setup_path_history(attrs)
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
    %w[state_store errors validation_context context_for_validation]
  end

  # Override in child classes #
  def initialize_extra(_attrs); end
  def setup_path_history(_attrs); end

  def sanitize_attrs(attrs)
    attrs
  end

  def sanitize_last_saved_state(last_saved_state, _attrs)
    last_saved_state
  end
  # Override in child classes #
end
