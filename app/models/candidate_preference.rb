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

  def create_draft_dup
    dup_record = dup
    dup_record.status = 'draft'

    location_preferences_attributes = []

    location_preferences.map do |location|
      location_preferences_attributes << location.attributes.except(
        'id',
        'candidate_preference_id',
        'created_at',
        'updated_at',
      )
    end

    ActiveRecord::Base.transaction do
      dup_record.save!
      dup_record.location_preferences.insert_all!(location_preferences_attributes)
    end

    dup_record
  end
end
