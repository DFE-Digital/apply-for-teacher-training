module Satisfactory
  class Root
    def initialize
      @types = Hash.new { |h, k| h[k] = [] }
    end

    def define_types
      Satisfactory.factory_configurations.each do |factory_name, config|
        type = config.fetch(:type)

        # Extract this
        case factory_name
        when :application_choice
          type.define(:part_time) do |t|
            t.modify do |ac|
              ac.with.course_option.part_time
            end
          end
        when :candidate
          type.define(:submitted_application) do |t, new_record: false|
            t.application_form(new_record:).submitted.modify do |form|
              form.with.application_choice
            end
          end

          type.define(:rejected_application) do |t, new_record: false|
            t.application_form(new_record:).modify do |form|
              form.with.application_choice.with_rejection
            end
          end
        end

        define_singleton_method(factory_name) do
          type.new(upstream: self).tap do |record|
            @types[factory_name] << record
          end
        end
      end
    end

    def create
      @types.transform_values do |records|
        records.each(&:create_self)
      end
    end

    def to_plan
      @types.transform_values do |records|
        records.map(&:build_plan)
      end
    end

    def upstream
      nil
    end
  end
end
