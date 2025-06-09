class CandidatePreference < ApplicationRecord
  belongs_to :candidate
  has_many :location_preferences, dependent: :destroy, class_name: 'CandidateLocationPreference'

  enum :pool_status, {
    opt_in: 'opt_in',
    opt_out: 'opt_out',
  }

  enum :status, {
    draft: 'draft',
    published: 'published',
  }

  enum :training_locations, {
    anywhere: 'anywhere',
    specific: 'specific',
  }, prefix: true

  def create_draft_dup
    dup_record = dup
    dup_record.status = 'draft'

    ActiveRecord::Base.transaction do
      dup_record.save!

      location_preferences.order(:created_at).each do |location|
        dup_record.location_preferences.create!(
          location.attributes.except(
            'id',
            'candidate_preference_id',
            'created_at',
            'updated_at',
          ),
        )
      end
    end

    dup_record
  end
end
