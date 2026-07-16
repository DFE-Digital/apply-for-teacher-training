module TestJob
  class DispatcherTestJob < ApplicationJob
    self.queue_adapter = :solid_queue

    def perform
      ids = Candidate.last(10).pluck(:id)
      BatchDelivery.new(
        relation: Candidate.where(id: ids),
        batch_size: 2,
        stagger_over: 30.minutes,
      ).each do |batch_time, records|
        DeliveryJob
          .set(wait_until: batch_time)
          .perform_later(records.pluck(:id))
      end
    end
  end

  class DeliveryJob < ApplicationJob
    self.queue_adapter = :solid_queue

    def perform(_ids)
      true
    end
  end
end
