class AddHandleInterviewsToProviders < ActiveRecord::Migration[8.0]
  create_enum :handle_interviews, %w[in_manage outside_service]

  def change
    add_column :providers, :handle_interviews, :enum, enum_type: 'handle_interviews', null: false, default: 'in_manage'
  end
end
