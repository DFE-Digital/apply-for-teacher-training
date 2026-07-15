module TestJob
  class SetUpJob < ApplicationJob
    self.queue_adapter = :solid_queue

    def perform
      return if HostingEnvironment.production?

      relation = ApplicationForm.all

      BatchDelivery.new(
        relation:,
        batch_size: 50,
        stagger_over: 1.hour,
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
