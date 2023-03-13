class Adviser::TeachingSubjects
  SUBJECTS_TO_EXCLUDE = [
    '6b793433-cd1f-e911-a979-000d3a20838a', # Art
    'a62655a1-2afa-e811-a981-000d3a276620', # Media studies
    'bc68e0c1-7212-e911-a974-000d3a206976', # No preference
    'bc2655a1-2afa-e811-a981-000d3a276620', # Other
    'ae2655a1-2afa-e811-a981-000d3a276620', # Physics with maths
    'ba2655a1-2afa-e811-a981-000d3a276620', # Vocational health
  ].freeze

  PRIMARY_SUBJECT_ID = 'b02655a1-2afa-e811-a981-000d3a276620'.freeze

  def all
    @all ||= secondary + [primary]
  end

  def secondary
    @secondary_teaching_subjects ||= teaching_subjects.reject do |subject|
      subject.id.in?(SUBJECTS_TO_EXCLUDE) || subject.id == PRIMARY_SUBJECT_ID
    end
  end

  def primary
    @primary_teaching_subject ||= teaching_subjects.find { |subject| subject.id == PRIMARY_SUBJECT_ID }
  end

private

  def teaching_subjects
    @teaching_subjects ||= GetIntoTeachingApiClient::LookupItemsApi.new.get_teaching_subjects
  end
end
