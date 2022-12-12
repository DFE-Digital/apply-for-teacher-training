require_relative "satisfactory/root"

module Satisfactory
  def self.root
    @root ||= Root.new.tap { |r| r.define_types }
  end

  def self.factory_configurations
    @factory_configurations ||= Loader.factory_configurations
  end
end
