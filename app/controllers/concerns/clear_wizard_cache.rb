module ClearWizardCache
  include ActiveSupport::Concern

private

  def clear_wizard_if_new_entry(wizard)
    return if entrypoint_in_wizard_flow?(wizard_flow_controllers, wizard_controller_excluded_paths)

    wizard.clear_state!
  end

  def entrypoint_in_wizard_flow?(controllers = [], excluded_paths = [])
    referer_path = request.referer ? URI(request.referer).path : nil
    recognised_path = Rails.application.routes.recognize_path(referer_path)

    excluded_paths.none? { |path| referer_path.eql?(path) } && controllers.include?(recognised_path[:controller])
  end
end
