module Hesa
  class Subject
    SubjectStruct = Struct.new(:hesa_code, :name)

    def self.all
      HESA_DEGREE_SUBJECTS.map { |subject_data| SubjectStruct.new(*subject_data) }
    end

    def self.names
      all.map(&:name)
    end
  end
end
