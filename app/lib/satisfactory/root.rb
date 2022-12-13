module Satisfactory
  class Root
    def initialize
      @root_records = Hash.new { |h, k| h[k] = [] }
    end

    def add(factory_name, **attributes)
      raise FactoryNotDefinedError, factory_name unless Satisfactory.factory_configurations.key?(factory_name)

      Satisfactory::Record.new(
        type: factory_name,
        upstream: self,
        attributes:,
      ).tap { |r| @root_records[factory_name] << r }
    end

    def create
      @root_records.transform_values do |records|
        records.map(&:create_self)
      end
    end

    def to_plan
      @root_records.transform_values do |records|
        records.map(&:build_plan)
      end
    end

    def upstream
      nil
    end
  end
end
