module CandidateInterface
  class BecomingATeacherForm
    include ActiveModel::Model

    attr_accessor :becoming_a_teacher, :single_personal_statement

    alias single_personal_statement? single_personal_statement

    validates :becoming_a_teacher, word_count: { maximum: 1000 }, if: :single_personal_statement?
    validates :becoming_a_teacher, word_count: { maximum: 600 }, unless: :single_personal_statement?

    delegate :blank?, to: :becoming_a_teacher

    def self.build_from_application(application_form)
      new(
        single_personal_statement: application_form.single_personal_statement?,
        becoming_a_teacher: application_form.becoming_a_teacher,
      )
    end

    def self.build_from_params(params)
      new(
        single_personal_statement: params[:single_personal_statement],
        becoming_a_teacher: params[:becoming_a_teacher],
      )
    end

    def save(application_form)
      application_form.update!(
        becoming_a_teacher:,
      )
    end

    def presence_of_statement
      if single_personal_statement? && becoming_a_teacher.blank?
        errors.add(:becoming_a_teacher, 'Write your personal statement')
      elsif becoming_a_teacher.blank?
        errors.add(:becoming_a_teacher, :blank)
      end
    end
  end
end
