class Proto::Connector
  def initialize(upstream:, count: nil)
    @upstream = upstream
    @count = count
  end

  attr_accessor :upstream

  def method_missing(method_name)
    if upstream.permitted?(method_name, with_count: true)
      upstream.public_send(method_name, count:, new_record:)
    elsif upstream.permitted?(method_name, with_count: false)
      upstream.public_send(method_name, new_record:)
    else
      super
    end
  end

private

  attr_reader :count, :new_record
end
