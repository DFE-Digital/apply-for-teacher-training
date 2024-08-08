class AddExperienceableToApplicationExperiences < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :application_experiences, :experienceable, polymorphic: true, null: true, index: { algorithm: :concurrently }
  end
end
