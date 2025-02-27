class Adviser::TeachingSubjectsService
  def all
    @all ||= secondary + [primary]
  end

  def secondary
    @secondary_teaching_subjects ||= teaching_subjects.reject do |subject|
      subject.id.in?(subject_ids_to_exclude) || subject.id == primary_subject_id
    end
  end

  def primary
    @primary_teaching_subject ||= teaching_subjects.find { |subject| subject.id == primary_subject_id }
  end

private

  def teaching_subjects
    @teaching_subjects ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_teaching_subjects
  end

  def subject_ids_to_exclude
    constants.fetch(:teaching_subjects, :excluded).values
  end

  def primary_subject_id
    constants.fetch(:teaching_subjects, :primary)
  end

  def constants
    Adviser::Constants
  end
end
