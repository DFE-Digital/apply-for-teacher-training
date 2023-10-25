module CandidateInterface
  class Section
    attr_accessor :id, :controller, :editable_condition

    def initialize(identifier, controller:, editable_condition: nil)
      @id = identifier
      @controller = controller
      @editable_condition = editable_condition
    end

    def name
      id.to_s.humanize
    end

    def science_gcse?(policy)
      params = policy.params
      current_application = policy.current_application
      subject = params[:subject]

      ((subject && subject == 'science') || policy.controller_path.include?('candidate_interface/gcse/science')) &&
        current_application
          .application_choices
          .select(&:science_gcse_needed?)
          .all?(&:unsubmitted?)
    end

    def maths_gcse?(_policy)
      subject = params[:subject]

      subject && subject == 'maths'
    end

    def english_gcse?(_policy)
      subject = params[:subject]

      subject && subject == 'english'
    end

    def eql?(other)
      id == other.id
    end

    def self.all
      [
        Section.new(:personal_details, controller: 'CandidateInterface::PersonalDetails'),
        Section.new(:contact_details, controller: 'CandidateInterface::ContactDetails'),
        Section.new(:training_with_a_disability, controller: 'CandidateInterface::TrainingWithADisability'),
        Section.new(:interview_preferences, controller: 'CandidateInterface::InterviewAvailability'),
        Section.new(:equality_and_diversity, controller: 'CandidateInterface::EqualityAndDiversity'),
        Section.new(:becoming_a_teacher, controller: 'CandidateInterface::PersonalStatement'),
        Section.new(
          :science_gcse,
          controller: 'CandidateInterface::Gcse',
          editable_condition: ->(section, policy) { section.science_gcse?(policy) },
        ),
        Section.new(
          :maths_gcse,
          controller: 'CandidateInterface::Gcse',
          editable_condition: ->(section, policy) { section.maths_gcse?(policy) },
        ),
        Section.new(
          :english_gcse,
          controller: 'CandidateInterface::Gcse',
          editable_condition: ->(section, policy) { section.english_gcse?(policy) },
        ),
        Section.new(:efl, controller: 'CandidateInterface::EnglishForeignLanguage'),
        Section.new(:references, controller: 'CandidateInterface::References'),
        Section.new(:safeguarding_issues, controller: 'CandidateInterface::Safeguarding'),
        Section.new(:other_qualifications, controller: 'CandidateInterface::OtherQualifications'),
        Section.new(:degrees, controller: 'CandidateInterface::Degrees'),
        Section.new(:volunteering, controller: 'CandidateInterface::Volunteering'),
        Section.new(:work_history, controller: 'CandidateInterface::RestructuredWorkHistory'),
      ]
    end

    def self.editable
      all.select { |section| section.id.in?(Rails.application.config.x.sections.editable) }
    end

    def self.non_editable
      all.difference(editable)
    end
  end
end
