module Hesa
  class Subject
    SubjectStruct = Struct.new(:hesa_code, :name)

    def self.all
      HESA_DEGREE_SUBJECTS.map { |subject_data| SubjectStruct.new(*subject_data) }
    end

    def self.names
      all.map(&:name)
    end

    def self.find_by_name(subject_name)
      all.find { |subject| subject.name == subject_name }
    end
  end
end
