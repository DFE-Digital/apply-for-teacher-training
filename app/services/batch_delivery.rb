class BatchDelivery
  attr_accessor :relation, :stagger_over, :batch_size

  def initialize(relation:, stagger_over: 5.hours, batch_size: 100)
    @relation = relation
    @stagger_over = stagger_over
    @batch_size = batch_size
  end

  def each(&block)
    next_batch_time = Time.zone.now
    relation_count = relation.send(count_method)
    interval_between_batches ||= begin
      number_of_batches = (relation_count.to_f / batch_size).ceil
      number_of_batches < 2 ? stagger_over : stagger_over / (number_of_batches - 1).to_f
    end

    batch_intervals(block:, relation:, batch_size:, next_batch_time:, interval_between_batches:)
  end

private

  def batch_intervals(block:, relation:, batch_size:, next_batch_time:, interval_between_batches:)
    relation.find_in_batches(batch_size:) do |applications|
      block.call(next_batch_time, applications)
      next_batch_time += interval_between_batches
    end
  end

  def count_method
    # The count_method depends on whether or not the relation is grouped or not for performance reasons
    # Use either GroupedRelationBatchDelivery if your relation is grouped.
    :count
  end
end
