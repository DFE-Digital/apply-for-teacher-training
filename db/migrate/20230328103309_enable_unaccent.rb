class EnableUnaccent < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'unaccent' unless extension_enabled?('unaccent')
  end
end
