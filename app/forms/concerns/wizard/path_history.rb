module Wizard::PathHistory
  extend ActiveSupport::Concern

  attr_accessor :wizard_path_history

  def setup_path_history(attrs)
    @path_history ||= [:referer]
    update_path_history(attrs)
  end

  def previous_step
    wizard_path_history.previous_step
  rescue WizardPathHistory::NoSuchStepError
    :referer
  end

private

  def update_path_history(attrs)
    @wizard_path_history = WizardPathHistory.new(@path_history,
                                                 step: attrs[:current_step].presence,
                                                 action: attrs[:action].presence)
    @wizard_path_history.update
    @path_history = @wizard_path_history.path_history
  end
end
