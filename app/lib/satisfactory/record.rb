class Satisfactory::Record
  def initialize(type:, factory_name: nil, upstream: nil)
    @factory_name = factory_name || type

    config = Satisfactory.factory_configurations[type]
    raise ArgumentError, "Unknown factory #{type}" unless config

    if (parent = config[:parent])
      @type = parent
    else
      @type = type
    end

    @type_config = Satisfactory.factory_configurations[@type]
    @traits = []
    @upstream = upstream

    @associations = type_config.dig(:associations, :plural).each.with_object({}) do |name, hash|
      hash[name] = Satisfactory::Collection.new(upstream: self)
    end
  end

  attr_accessor :type, :type_config, :traits, :upstream, :factory_name

  # Tidy this up later
  def with(count = nil, downstream_type, force: false)
    if singular?(downstream_type)
      raise ArgumentError, "Cannot create multiple of singular associations (e.g. belongs_to)" if count && count > 1

      add_singular_association(downstream_type, factory_name: downstream_type, force:)
    elsif plural?(downstream_type) && (singular = singular_from_plural(downstream_type))
      add_plural_association(downstream_type, factory_name: singular, count:, force:)
    elsif (config = Satisfactory.factory_configurations[downstream_type])
      singular = config[:parent] || downstream_type
      plural = plural_from_singular(singular)
      add_singular_for_plural_association(plural, singular:, factory_name: downstream_type, force:)
    elsif (config = Satisfactory.factory_configurations[downstream_type.to_s.singularize])
      if (parent = config[:parent])
        plural = plural_from_singular(parent)
        add_plural_association(plural, factory_name: downstream_type.to_s.singularize, count:, force:)
      else
        raise ArgumentError, "Cannot create multiple of singular associations (e.g. belongs_to)"
      end
    else
      raise ArgumentError, "Unknown association #{type}->#{downstream_type}"
    end
  end

  def and(*args)
    upstream.with(*args, force: true)
  end

  def which_is(*traits)
    traits.each { |trait| self.traits << trait }
    self
  end

  def and_same(upstream_type)
    Satisfactory::UpstreamRecordFinder.new(upstream:).find(upstream_type)
  end

  def modify
    yield(self).upstream
  end

  def create
    if upstream
      upstream.create
    else
      create_self
    end
  end

  def to_plan
    if upstream
      upstream.to_plan
    else
      build_plan
    end
  end

  def build_plan
    {
      traits:,
    }.merge(associations_plan).compact_blank
  end

  def build
    reify(:build)
  end

  def create_self
    reify(:create)
  end

private

  attr_reader :associations

  def reify(method)
    FactoryBot.public_send(method, factory_name, *traits, associations.transform_values(&:build))
  end

  def associations_plan
    associations.transform_values(&:build_plan).compact_blank
  end

  def plural?(association_name)
    type_config.dig(:associations, :plural).include?(association_name)
  end

  def singular?(association_name)
    type_config.dig(:associations, :singular).include?(association_name)
  end

  def plural_from_singular(singular_association_name)
    type_config.dig(:associations, :plural).find do |name|
      singular_association_name.to_s == name.to_s.singularize
    end
  end

  def singular_from_plural(plural_association_name)
    Satisfactory.factory_configurations.keys.find do |name|
      plural_association_name.to_s == name.to_s.pluralize
    end
  end

  def add_singular_association(name, factory_name:, force: false)
    if force || associations[name].blank?
      associations[name] = self.class.new(type: name, factory_name:, upstream: self)
    else
      associations[name]
    end
  end

  def add_plural_association(name, factory_name:, count: nil, force: false)
    count ||= 1
    singular_name = name.to_s.singularize.to_sym

    Satisfactory::Collection.new(upstream: self).tap do |new_associations|
      count.times do
        new_associations << self.class.new(type: singular_name, factory_name:, upstream: self)
      end

      if force
        associations[name] << new_associations
      else
        associations[name] = new_associations
      end
    end
  end

  def add_singular_for_plural_association(name, singular:, factory_name:, force: false)
    if force || associations[name].empty?
      associations[name] << self.class.new(type: singular, factory_name:, upstream: self)
    end

    associations[name].last
  end
end
