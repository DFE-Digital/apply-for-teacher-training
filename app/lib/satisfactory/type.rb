class Satisfactory::Type
  def self.define_from(config)
    define_class.tap do |type|
      type.config = config
      type.custom = {}
    end
  end

  def self.define_class
    Class.new(Satisfactory::Record) do
      cattr_accessor :config, :custom

      def self.define(type_name, &block)
        custom[type_name] = block
      end

      def self.inspect
        "#<Satisfactory::Type(#{name})>"
      end

      def self.name
        config.fetch(:name).to_s
      end

      def initialize(...)
        super(...)

        @associations = config.dig(:associations, :plural).each.with_object({}) do |name, hash|
          hash[name] = Satisfactory::Collection.new(upstream: self)
        end
      end

      attr_reader :associations

      def inspect
        "#<Satisfactory::Type(#{self.class.name}):0x#{object_id.to_s(16)}>"
      end

      def method_missing(method_name, *_args, new_record: false, count: nil, **_kwargs, &_block)
        case method_name
        when *custom.keys
          custom[method_name].call(self, new_record:)
        when *config.fetch(:traits).map(&:to_sym)
          traits << method_name
          self
        when *config.dig(:associations, :singular)
          singular_association(method_name, new_record:)
        when *config.dig(:associations, :plural)
          plural_association(method_name, new_record:, count:)
        else
          if (plural = config.dig(:associations, :plural).find { |n| method_name.to_s == n.to_s.singularize })
            singular_association_for_plural(method_name, new_record:, plural:)
          else
            super
          end
        end
      end

      def respond_to_missing?(method_name, _include_private = false)
        custom.keys.include?(method_name) ||
          config.fetch(:traits).include?(method_name) ||
          config.dig(:associations, :singular).include?(method_name) ||
          config.dig(:associations, :plural).include?(method_name) ||
          config.dig(:associations, :plural).any? { |n| method_name.to_s == n.to_s.singularize } ||
          super
      end

      def permitted?(method_name, with_count: false)
        if with_count
          config.dig(:associations, :plural).include?(method_name)
        else
          custom.keys.include?(method_name) ||
            config.fetch(:traits).include?(method_name) ||
            config.dig(:associations, :singular).include?(method_name) ||
            config.dig(:associations, :plural).any? do |name|
              method_name.to_s == name.to_s.singularize
            end
        end
      end

      def build
        FactoryBot.build(config.fetch(:name), *traits,
                         associations.transform_values(&:build))
      end

      def create_self
        FactoryBot.create(config.fetch(:name), *traits,
                          associations.transform_values(&:build))
      end

    private

      def config
        self.class.config
      end

      def associations_plan
        associations.transform_values(&:build_plan).compact_blank
      end

      def singular_association(name, new_record: false)
        if new_record || associations[name].blank?
          association_type = Satisfactory.factory_configurations.dig(name.to_sym, :type)
          associations[name] = association_type.new(upstream: self)
        else
          associations[name]
        end
      end

      def plural_association(name, new_record: false, count: nil)
        count ||= 3
        singular_name = name.to_s.singularize.to_sym
        association_type = Satisfactory.factory_configurations.dig(singular_name, :type)

        Satisfactory::Collection.new(upstream: self).tap do |new_associations|
          count.times do
            new_associations.add(association_type.new)
          end

          if new_record
            associations[name].add(new_associations)
          else
            associations[name] = new_associations
          end
        end
      end

      def singular_association_for_plural(name, new_record: false, plural: nil)
        association_name = plural || name
        association_type = Satisfactory.factory_configurations.dig(name.to_sym, :type)

        if new_record || associations[association_name].empty?
          associations[association_name].add(association_type.new, singular: true)
        else
          associations[association_name].last
        end
      end
    end
  end
end
