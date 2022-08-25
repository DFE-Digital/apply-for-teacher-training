class BatchDelivery
  attr_accessor :relation, :stagger_over, :batch_size

  def initialize(relation:, stagger_over: 5.hours, batch_size: 100)
    @relation = relation
    @stagger_over = stagger_over
    @batch_size = batch_size
  end

  def each(&block)
    batches.each do |perform_at, records|
      block.call(perform_at, records)
    end
  end

  def batches
    next_batch_time = Time.zone.now
    batches_schedule = []
    relation_count = relation.count

    relation.find_in_batches(batch_size:) do |applications|
      interval_between_batches ||= begin
        number_of_batches = (relation_count.to_f / batch_size).ceil
        number_of_batches < 2 ? stagger_over : stagger_over / (number_of_batches - 1).to_f
      end

      batches_schedule << [next_batch_time, applications]

      next_batch_time += interval_between_batches
    end

    batches_schedule
  end
end
