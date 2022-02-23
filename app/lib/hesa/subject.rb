module Hesa
  class Subject
    include ActiveModel::Model
    attr_accessor :id, :hesa_code, :name, :synonyms, :dttp_id
    alias hesa_itt_code= hesa_code=

    def self.all
      DfE::ReferenceData::Degrees::SUBJECTS.all.map do |subject_data|
        new(subject_data.to_h)
      end
    end

    def self.names
      all.map(&:name)
    end

    def self.find_by_name(subject_name)
      all.find { |subject| subject.name == subject_name }
    end
  end
end
