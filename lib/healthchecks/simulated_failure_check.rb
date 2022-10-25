class Healthchecks::SimulatedFailureCheck < OkComputer::Check
  def check
    if FeatureFlag.active?('force_ok_computer_to_fail')
      mark_failure
      mark_message 'force_ok_computer_to_fail is on'
    else
      mark_message 'force_ok_computer_to_fail is off'
    end
  end
end
