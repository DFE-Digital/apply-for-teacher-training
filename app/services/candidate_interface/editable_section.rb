module CandidateInterface
  class EditableSection
    include ActiveModel::Model
    attr_accessor :current_application, :controller_path, :action_name, :params

    Section = Struct.new(:controller, :condition, keyword_init: true)

    def self.all
      [
        Section.new(controller: 'CandidateInterface::PersonalDetails'),
        Section.new(controller: 'CandidateInterface::ContactDetails'),
        Section.new(controller: 'CandidateInterface::TrainingWithADisability'),
        Section.new(controller: 'CandidateInterface::InterviewAvailability'),
        Section.new(controller: 'CandidateInterface::EqualityAndDiversity'),
        Section.new(controller: 'CandidateInterface::PersonalStatement'),
        Section.new(controller: 'CandidateInterface::Gcse', condition: :science_gcse?),
      ]
    end

    def can_edit?
      any_offer_accepted? || all_applications_unsubmitted? || editable_section?
    end

    delegate :any_offer_accepted?, to: :current_application

    def all_applications_unsubmitted?
      current_application.application_choices.all?(&:unsubmitted?)
    end

    def editable_section?
      EditableSection.all.any? do |section|
        controller_match = @controller_path.classify =~ /#{section.controller}/

        if controller_match.present? && section.condition.present?
          public_send(section.condition)
        else
          controller_match
        end
      end
    end

    def science_gcse?
      params[:subject] &&
        params[:subject] == 'science' &&
        current_application
          .application_choices
          .select(&:science_gcse_needed?)
          .all?(&:unsubmitted?)
    end
  end
end
