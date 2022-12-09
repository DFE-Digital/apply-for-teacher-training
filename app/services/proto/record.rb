class Proto::Record
  def initialize(upstream: nil)
    @traits = []
    @upstream = upstream
  end

  attr_accessor :traits, :upstream

  def with(count = nil, new_record: false)
    Proto::With.new(upstream: self, count:, new_record:)
  end

  def and(count = nil)
    upstream.with(count, new_record: true)
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

private

  def associations_plan
    {}
  end
end
