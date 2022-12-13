class Satisfactory::Collection < Array
  def initialize(*args, upstream:, **kwargs, &block)
    super(*args, **kwargs, &block)
    @upstream = upstream
  end

  attr_reader :upstream

  delegate :and, :create, :to_plan, to: :upstream

  def with(...)
    self.class.new(map { |entry| entry.with(...) }, upstream:)
  end
  alias each_with with

  def which_are(...)
    self.class.new(map { |entry| entry.which_is(...) }, upstream:)
  end
  alias which_is which_are

  def and_same(upstream_type)
    Satisfactory::UpstreamRecordFinder.new(upstream:).find(upstream_type)
  end

  def build
    flat_map(&:build)
  end

  def build_plan
    flat_map(&:build_plan)
  end
end
