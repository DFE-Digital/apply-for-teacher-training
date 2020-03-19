class MoveDeliveryStatusToNotTracked < ActiveRecord::Migration[6.0]
  def up
    execute "UPDATE emails SET delivery_status = 'not_tracked' WHERE delivery_status = 'unknown'"
  end
end
