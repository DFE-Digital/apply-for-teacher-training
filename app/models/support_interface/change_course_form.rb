module SupportInterface
  class ChangeCourseForm
    include ActiveModel::Model
    attr_accessor :change_type, :application_form

    validates :change_type, presence: true

    def can_withdraw_course?
      active_application_choices.count > 1
    end

    def can_add_course?
      active_application_choices.count < 3
    end

  private

    def active_application_choices
      application_form.application_choices.where(status: %w[awaiting_references application_complete])
    end
  end
end
