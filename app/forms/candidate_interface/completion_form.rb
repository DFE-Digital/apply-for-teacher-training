module CandidateInterface
  class CompletionForm
    include ActiveModel::Model

    def self.build_from_application(attr_hash)
      attr = attr_hash.keys.first

      create_attr_accessor_from(attr)
      create_validation_from(attr)

      new(attr_hash)
    end

    def self.create_attr_accessor_from(attr)
      instance_eval do
        attr_accessor attr
      end
    end

    def self.create_validation_from(attr)
      instance_eval do
        validates attr, presence: true
      end
    end

    def save(application_form, attr)
      return false unless valid?

      application_form.update!(attr => send(attr))
    end
  end
end
