module CandidateInterface
  class EditableSection
    include ActiveModel::Model
    attr_accessor :current_application, :controller_path, :action_name, :params

    Section = Struct.new(:controller, :conditions, keyword_init: true)

    def self.all
      [
        Section.new(controller: 'CandidateInterface::PersonalDetails'),
        Section.new(controller: 'CandidateInterface::ContactDetails'),
        Section.new(controller: 'CandidateInterface::TrainingWithADisability'),
        Section.new(controller: 'CandidateInterface::InterviewAvailability'),
        Section.new(controller: 'CandidateInterface::EqualityAndDiversity'),
        Section.new(controller: 'CandidateInterface::PersonalStatement'),
        #      'candidate_interface/gsce/review' => { conditions: { subject: 'science', status: :unsubmitted } },
      ]
    end

    def can_edit?
      all_applications_unsubmitted? || editable_section?
    end

    def all_applications_unsubmitted?
      current_application.application_choices.all?(&:unsubmitted?)
    end

    def editable_section?
      EditableSection.all.any? do |section|
        @controller_path.classify =~ /#{section.controller}/
      end
    end
  end
end
