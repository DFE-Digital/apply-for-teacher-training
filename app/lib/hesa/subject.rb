module Hesa
  class Subject
    include ActiveModel::Model

    attr_accessor :id, :name, :suggestion_synonyms, :match_synonyms, :hecos_code, :dttp_id, :subject_ids, :comment
    alias hesa_code= hecos_code=
    alias hesa_code hecos_code

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
