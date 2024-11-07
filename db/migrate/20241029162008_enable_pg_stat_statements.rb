class EnablePgStatStatements < ActiveRecord::Migration[7.2]
  def change
    enable_extension 'pg_stat_statements'
  end
end
