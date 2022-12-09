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

  def part_time
    tap do |collection|
      collection.map(&:part_time)
    end
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
