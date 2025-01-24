class AddErrorTypeToSessionError < ActiveRecord::Migration[8.0]
  def change
    add_column(:session_errors, :error_type, :string, default: 'internal')
  end
end
