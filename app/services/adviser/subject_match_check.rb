class Adviser::SubjectMatchCheck
  def self.quickfire_subject_match?(degree)
    new(degree).call
  end

  def initialize(degree)
    @degree = degree
  end

  def call
    try_subject_uuid || try_exact_name || try_synonyms || try_match_against_input
  end

private

  def try_subject_uuid
    @degree.degree_subject_uuid.in? subject_uuids
  end

  def try_exact_name
    relevant_subjects.any? do |relevant_subject|
      (relevant_subject.name.downcase == subject_name)
    end
  end

  def try_synonyms
    relevant_subjects.any? do |relevant_subject|
      subject_name.in?(relevant_subject.match_synonyms.map(&:downcase)) || # Exact match on any of the synonyms
        subject_name.in?(relevant_subject.suggestion_synonyms.map(&:downcase)) # || # Exact match on any of the suggestions
    end
  end

  def try_match_against_input
    file = Rails.root.join('config/initializers/subject-adviser-match-data.csv').read
    csv = CSV.parse(file, headers: true)

    csv.any? { |row| subject_name == row['subject_input'] }
  end

  def relevant_subjects
    @relevant_subjects ||= Hesa::Subject.all.filter { |s| s.id.in? subject_uuids }
  end

  def subject_name
    @subject_name ||= @degree.subject.strip.downcase
  end

  def subject_uuids
    SUBJECT_UUIDS_FOR_QUICKFIRE_SIGN_UP
  end
end
