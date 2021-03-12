class BackFillEnicReferences < ActiveRecord::Migration[6.0]
  def change
    ApplicationQualification
      .where.not(naric_reference: nil)
      .where(enic_reference: nil)
      .find_each do |qualification|
      qualification.update!(enic_reference: qualification.naric_reference)
    end
  end
end
