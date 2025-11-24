class ArrayBatchDelivery < BatchDelivery
  def batch_intervals(block:, relation:, batch_size:, next_batch_time:, interval_between_batches:)
    relation.each_slice(batch_size) do |applications|
      block.call(next_batch_time, applications)
      next_batch_time += interval_between_batches
    end
  end
end
