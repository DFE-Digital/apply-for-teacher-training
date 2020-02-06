class BackfillRefereeChasers < ActiveRecord::Migration[6.0]
  def change
    references = ApplicationReference
                  .feedback_requested
                  .where(['created_at < ?', Time.zone.now - 5.days])
                  .where.not(id: ChaserSent.reference_request.select(:chased_id))

    references.each { |reference| ChaserSent.create!(chased: reference, chaser_type: :reference_request) }
  end
end
