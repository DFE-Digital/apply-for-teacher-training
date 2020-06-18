module CandidateInterface
  class BecomingATeacherForm
    include ActiveModel::Model

    attr_accessor :becoming_a_teacher

    validates :becoming_a_teacher,
              word_count: { maximum: 600 },
              presence: true

    def self.build_from_application(application_form)
      new(
        becoming_a_teacher: application_form.becoming_a_teacher,
      )
    end

    def save(application_form)
      return false unless valid?

      application_form.update(
        becoming_a_teacher: becoming_a_teacher,
      )
    end
  end
end
