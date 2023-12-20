module CandidateInterface
  class BecomingATeacherForm
    include ActiveModel::Model

    attr_accessor :becoming_a_teacher

    validates :becoming_a_teacher, word_count: { maximum: 1000 }
    validates :becoming_a_teacher, presence: true

    def self.build_from_application(application_form)
      new(
        becoming_a_teacher: application_form.becoming_a_teacher,
      )
    end

    def self.build_from_params(params)
      new(
        becoming_a_teacher: params[:becoming_a_teacher],
      )
    end

    def save(application_form)
      return false unless valid?

      if application_form.continuous_applications?
        application_form.update!(
          becoming_a_teacher:,
        )
      else
        ActiveRecord::Base.transaction do
          application_form.update!(
            becoming_a_teacher:,
          )

          application_form
            .application_choices
            .all? { |choice| choice.update!(personal_statement: becoming_a_teacher) }
        end
      end
    end
  end
end
