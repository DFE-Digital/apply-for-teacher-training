class Proto::Collection < Array
  def initialize(*args, upstream:, **kwargs, &block)
    super(*args, **kwargs, &block)
    @upstream = upstream
  end

  attr_reader :upstream

  def add(entry, singular: true)
    entry.upstream = @upstream unless entry.is_a?(Proto::Collection)
    self << entry

    singular ? entry : self
  end

  delegate :create, :to_plan, to: :upstream

  def method_missing(method_name, *_args)
    if empty? || !first.permitted?(method_name)
      super
    else
      self.class.new(map(&method_name), upstream:)
    end
  end

  def respond_to_missing?(method_name, _include_private = false)
    !empty? && first.permitted?(method_name) || super
  end

  def build
    flat_map(&:build)
  end

  def build_plan
    flat_map(&:build_plan)
  end

  def and(...)
    upstream.and(...)
  end
end
