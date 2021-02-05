class BackfillQualificationPublicId
  def initialize(qualification)
    @qualification = qualification
  end

  def call
    if @qualification.constituent_grades.present?
      grades_with_ids = @qualification.constituent_grades.transform_values.with_index do |grade, index|
        next grade if grade['public_id'].present?

        public_id = index.zero? ? @qualification.id : next_public_id
        grade.merge({ public_id: public_id })
      end

      @qualification.update_columns(constituent_grades: grades_with_ids)
    elsif @qualification.public_id.blank?
      @qualification.update_columns(public_id: @qualification.id)
    end
  end

private

  def next_public_id
    ActiveRecord::Base.nextval(:qualifications_public_id_seq)
  end
end
