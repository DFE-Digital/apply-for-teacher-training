class AddPostcodeToProviders < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :postcode, :string
  end
end
