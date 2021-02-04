class AddQualificationPublicIdSequence < ActiveRecord::Migration[6.0]
  def up
    max_qualification_id = ApplicationQualification.maximum(:id)
    create_sequence :qualifications_public_id_seq, start: max_qualification_id * 2
  end

  def down
    drop_sequence :qualifications_public_id_seq
  end
end
