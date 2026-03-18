class EnglishProficiency < ApplicationRecord
  include TouchApplicationChoices

  audited associated_with: :application_form

  belongs_to :application_form
  belongs_to :efl_qualification, polymorphic: true, optional: true, dependent: :destroy

  enum :qualification_status, {
    has_qualification: 'has_qualification',
    no_qualification: 'no_qualification',
    qualification_not_needed: 'qualification_not_needed',
    degree_taught_in_english: 'degree_taught_in_english',
  }

  scope :draft, -> { where(draft: true) }

  def formatted_qualification_description
    return if efl_qualification.blank?

    name = "Name: #{efl_qualification.name}"
    grade = "Grade: #{efl_qualification.grade}"
    award_year = "Awarded: #{efl_qualification.award_year}"
    reference = "Reference: #{efl_qualification.unique_reference_number}" if efl_qualification.unique_reference_number.present?

    [name, grade, award_year, reference].compact.join(', ')
  end

  def create_draft_dup!
    application_form.english_proficiencies.draft.destroy_all

    dup_record = dup
    dup_record.draft = true
    dup_record.save!
    dup_record
  end

  def publish!
    ActiveRecord::Base.transaction do
      application_form.english_proficiencies.where.not(id: id).destroy_all

      self.draft = false
      save!
    end
  end

  def qualification_statuses
    statuses = []
    EnglishProficiency.qualification_statuses.each_key do |key|
      statuses << key if try(key)
    end

    statuses
  end
end
