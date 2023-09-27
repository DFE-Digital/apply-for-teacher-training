class AddUniqueIndexOnAppChoiceForDuplicableStatus < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  UNIQUE_STATES = "'awaiting_provider_decision', 'interviewing', 'pending_conditions', 'conditions_not_met', 'recruited', 'offer', 'offer_defered', 'inactive', 'unsubmitted'".freeze
  def change
    add_index :application_choices, "application_form_id, course_option_id, (CASE WHEN status IN (#{UNIQUE_STATES}) THEN 'u' ELSE status END)", unique: true, where: "status IN (#{UNIQUE_STATES});", name: 'index_application_form_id_and_course_option_id_and_status', algorithm: :concurrently
  end
end
