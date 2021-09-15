module Wizard
  extend ActiveSupport::Concern

  include ActiveModel::Model

  included do
    attr_accessor :current_step, :action, :referer
    attr_reader :state_store
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
