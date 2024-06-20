class AddGovukOneLoginToCandidateTable < ActiveRecord::Migration[7.1]
  def change
    add_column :candidates, :govuk_one_login_uid, :string
  end
end
