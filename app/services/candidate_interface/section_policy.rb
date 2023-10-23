module CandidateInterface
  class SectionPolicy
    attr_accessor :current_application, :controller_path, :action_name, :params

    def initialize(current_application:, controller_path:, action_name:, params:)
      @current_application = current_application
      @controller_path = controller_path
      @action_name = action_name
      @params = params
    end

    def self.editable_sections
      [
        Section.new(controller: 'CandidateInterface::PersonalDetails'),
        Section.new(controller: 'CandidateInterface::ContactDetails'),
        Section.new(controller: 'CandidateInterface::TrainingWithADisability'),
        Section.new(controller: 'CandidateInterface::InterviewAvailability'),
        Section.new(controller: 'CandidateInterface::EqualityAndDiversity'),
        Section.new(controller: 'CandidateInterface::PersonalStatement'),
        Section.new(
          controller: 'CandidateInterface::Gcse',
          condition: ->(section, policy) { section.science_gcse?(policy) },
        ),
        Section.new(controller: 'CandidateInterface::EnglishForeignLanguage'),
      ]
    end

    def can_edit?
      five_days_after_first_submission? ||
        any_offer_accepted? ||
        all_applications_unsubmitted? ||
        editable_section?
    end

    def five_days_after_first_submission?
      @current_application.submitted_at.present? &&
        5.business_days.after(@current_application.submitted_at).end_of_day >= Time.zone.now
    end

    def personal_statement?
      @controller_path.classify.eql?('CandidateInterface::PersonalStatement')
    end

  private

    delegate :any_offer_accepted?, to: :current_application

    def all_applications_unsubmitted?
      current_application.application_choices.all?(&:unsubmitted?)
    end

    def editable_section?
      self.class.editable_sections.any? do |section|
        controller_match = @controller_path.classify =~ /#{section.controller}/

        if controller_match.present? && section.condition.present?
          section.condition.call(section, self)
        else
          controller_match
        end
      end
    end
  end
end
