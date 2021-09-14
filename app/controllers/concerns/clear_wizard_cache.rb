module ClearWizardCache
  include ActiveSupport::Concern

private

  def clear_wizard_if_new_entry(wizard)
    if (wizard_entrypoint_paths.any? && referer_is_wizard_flow_entrypoint?) ||
       (wizard_flow_controllers.any? && !referer_in_wizard_flow?(wizard_flow_controllers, wizard_controller_excluded_paths))
      wizard.clear_state!
    elsif wizard_entrypoint_paths.none? && wizard_flow_controllers.none?
      raise 'Specify either the `wizard_flow_controllers` or `wizard_entrypoint_paths`'
    end
  end

  def referer_in_wizard_flow?(controllers = [], excluded_paths = [])
    recognised_path = Rails.application.routes.recognize_path(referer_path)

    excluded_paths.none? { |path| referer_path.eql?(path) } && controllers.include?(recognised_path[:controller])
  end

  def referer_is_wizard_flow_entrypoint?
    wizard_entrypoint_paths.include?(referer_path)
  end

  def referer_path
    @referer_path ||= request.referer ? URI(request.referer).path : nil
  end

  def wizard_entrypoint_paths
    []
  end

  def wizard_flow_controllers
    []
  end
end
