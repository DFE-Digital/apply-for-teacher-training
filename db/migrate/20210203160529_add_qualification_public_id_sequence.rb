class AddQualificationPublicIdSequence < ActiveRecord::Migration[6.0]
  def up
    # We set the start of the sequence to be twice the max id for qualifications that currently exist.
    # It is important that the public_id does not clash with any existing ids from the database
    # See adr/0018-public-ids-for-qualifications.md for more details
    max_qualification_id = 60000
    create_sequence :qualifications_public_id_seq, start: max_qualification_id * 2
  end

  def down
    drop_sequence :qualifications_public_id_seq
  end
end
