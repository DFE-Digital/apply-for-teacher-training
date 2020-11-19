module CandidateInterface
  class OtherQualificationDetailForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ValidationUtils

    attr_reader :next_step
    attr_accessor :checking_answers, :id, :current_step

    attr_accessor :qualification_type
    attr_accessor :other_uk_qualification_type
    attr_accessor :non_uk_qualification_type
    attr_accessor :subject
    attr_accessor :grade
    attr_accessor :predicted_grade
    attr_accessor :award_year
    attr_accessor :institution_country
    attr_accessor :choice

    validates :qualification_type, presence: true
    validates :award_year, presence: true
    validates :subject, :grade, presence: true, if: -> { qualification_type != 'non_uk' && qualification_type != 'Other' }
    validates :subject, :grade, length: { maximum: 255 }
    validates :institution_country, presence: true, if: -> { qualification_type == 'non_uk' }
    validates :institution_country, inclusion: { in: COUNTRIES }, if: -> { qualification_type == 'non_uk' }
    validate :award_year_is_date_and_before_current_year, if: :award_year

    def self.build_all(application_form)
      application_form.application_qualifications.other.order(:created_at).map do |qualification|
        build_from_qualification(qualification)
      end
    end

    def self.build_from_qualification(qualification)
      form = CandidateInterface::OtherQualificationDetailForm.new
      form.id = qualification.id
      form.assign_attributes(form.persistent_attributes(qualification))
      form
    end

    def initialize(current_application = nil, intermediate_data_service = nil, options = {})
      @current_application = current_application
      @intermediate_data_service = intermediate_data_service
      options.merge!(@intermediate_data_service.read) if @intermediate_data_service
      super(options)
    end

    def save_intermediate!
      @intermediate_data_service.write(intermediate_state)
    end

    def save!
      @next_step = :check

      application_qualification =
        if id.present?
          current_qualification = @current_application.application_qualifications.other.find(params[:id])
        else
          @current_application.application_qualifications.build(
            level: ApplicationQualification.levels[:other],
          )
        end

      application_qualification.assign_attributes(attributes_for_persistence)
      application_qualification.save!
    end

    def initialize_new_qualification(qualifications)
      return if qualifications.blank?

      if previous_qualification_is_of_same_type?(qualifications)
        self.institution_country ||= qualifications[-1].institution_country
        self.award_year ||= qualifications[-1].award_year
      end
      if qualification_type == 'non_uk'
        self.non_uk_qualification_type ||= qualifications[-1].non_uk_qualification_type
      elsif qualification_type == 'Other'
        self.other_uk_qualification_type ||= qualifications[-1].other_uk_qualification_type
      end
    end

    def qualification_type_name
      if qualification_type == 'non_uk'
        non_uk_qualification_type
      elsif qualification_type == 'Other' && other_uk_qualification_type.present?
        other_uk_qualification_type
      else
        qualification_type
      end
    end

    def title
      "#{qualification_type_name} #{subject}"
    end

    PERSISTENT_ATTRIBUTES = %w[qualification_type other_uk_qualification_type non_uk_qualification_type subject predicted_grade grade award_year institution_country].freeze
    def persistent_attributes(application_qualification)
      application_qualification.attributes.select { |key, _| PERSISTENT_ATTRIBUTES.include?(key) }
    end

    def missing_type_validation_error?
      valid?
      errors.details[:qualification_type].any? { |e| e[:error] == :blank }
    end

  private

    def previous_qualification_is_of_same_type?(qualifications)
      last_qualification = qualifications[-1]
      qualification_type == last_qualification.qualification_type
    end

    def attributes_for_persistence
      {
        qualification_type: qualification_type,
        subject: subject,
        institution_country: institution_country,
        predicted_grade: predicted_grade,
        grade: grade,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
        award_year: award_year,
      }
    end

    def intermediate_state
      as_json(
        only: %w[id current_step checking_answers subject institution_country predicted_grade grade award_year],
      )
    end

    def award_year_is_date_and_before_current_year
      year_limit = Time.zone.today.year.to_i + 1

      if !valid_year?(award_year)
        errors.add(:award_year, :invalid)
      elsif award_year.to_i >= year_limit
        errors.add(:award_year, :in_the_future, date: year_limit)
      end
    end
  end
end
