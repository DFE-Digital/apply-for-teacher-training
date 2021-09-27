class RecreateQualificationsPublicIdSequence < ActiveRecord::Migration[6.1]
  def change
    create_sequence 'qualifications_public_id_seq', start: 120000
  end
end
