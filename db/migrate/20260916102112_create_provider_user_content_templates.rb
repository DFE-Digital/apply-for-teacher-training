class CreateProviderUserContentTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_user_content_templates do |t|
      t.references :provider_user, null: false, foreign_key: true
      t.string :kind, null: false
      t.text :body, null: false
      t.boolean :in_use, default: false, null: false

      t.timestamps
    end
  end
end
