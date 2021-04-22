class WizardPathHistory
  PREVIOUS_STEP_INDEX = -2

  class NoSuchStepError < StandardError
    def message
      'Invalid wizard step'
    end
  end

  attr_accessor :path_history, :step, :action

  def initialize(path_history, step: nil, action: nil)
    @path_history = path_history || []
    @step = step
    @action = action
  end

  def update
    if action == 'back'
      path_history.pop
    elsif step && !path_history.last.eql?(step)
      path_history << step
    end
  end

  def previous_step
    raise NoSuchStepError unless path_history.rindex(step)

    path_history[path_history.rindex(step) - 1]
  end
end
