class VersionChange
  def resources
    {}
  end

  def self.description(text)
    define_method(:description) { text }
  end

  def self.action(controller, controller_action)
    define_method(:actions) do
      controller_actions = {}
      controller_actions[controller] ||= []
      controller_actions[controller] << controller_action
      controller_actions
    end
  end

  def self.resource(resource, modules = [])
    resources = new.resources

    define_method(:resources) do
      resources[resource] ||= []
      resources[resource] |= modules
      resources
    end
  end
end
