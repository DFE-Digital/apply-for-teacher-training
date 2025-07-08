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

  enum :course_type, {
    fee: 'fee',
    salary: 'salary',
  }, prefix: true

  delegate :applied_only_to_salaried_courses?, to: :candidate

  ## Show the course type option on review page only if they applied only salary courses or have already aswered this question
  ## The provider filter would look at the preference table, if nil we infer a preference from application choice history

  ## Form
  # Redirect from anywhere in england
  # Or from dynamic locations
  #
  # Test review page with course_type
  # With no course type but with applications only to salary
  #
  # When changing, we should always show the course type preference. Populated or link
  #
  #
  #Validation when prvoider invite based on fee prefence? The filter is optional.. NO



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
