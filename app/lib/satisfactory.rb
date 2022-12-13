require_relative "satisfactory/root"

module Satisfactory
  def self.root
    Root.new
  end

  def self.factory_configurations
    @factory_configurations ||= Loader.factory_configurations
  end
end
