class Satisfactory::Record
  def initialize(upstream: nil)
    @traits = []
    @upstream = upstream
  end

  attr_accessor :traits, :upstream

  def with(count = nil)
    Satisfactory::With.new(upstream: self, count:)
  end

  def and(count = nil)
    Satisfactory::And.new(upstream:, count:)
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
    }.merge(associations_plan)
  end

  def permitted?(method_name, with_count: false)
    if with_count
      permitted_with_count.include?(method_name)
    else
      permitted_without_count.include?(method_name)
    end
  end

private

  def associations_plan
    {}
  end

  def permitted_with_count
    [].freeze
  end

  def permitted_without_count
    [].freeze
  end
end
