module CandidateInterface
  class Gcse::NewInternationalFlow::BaseController < SectionController
    include GcseStatementComparabilityPathHelper

    before_action :redirect_if_feature_flag_inactive
    before_action :set_subject
    before_action :set_institution_country
    before_action :set_equivalent_qualifications
    before_action :set_structured_grades
    before_action :render_application_feedback_component

  private

    def set_subject
      @subject = subject_param
    end

    def current_qualification
      @current_qualification ||= current_application.qualification_in_subject(:gcse, @subject)
    end

    def set_institution_country
      @institution_country ||= current_qualification.institution_country
    end

    def set_equivalent_qualifications
      return if @institution_country.blank?

      @equivalent_qualifications ||= finder.equivalent_qualifications
    end

    def set_structured_grades
      @structured_grades ||=
        if selected_grade_schema.present?
          selected_grade_schema.likely_above_level_four +
            selected_grade_schema.likely_below_level_four
        else
          []
        end
    end

    def selected_grade_schema
      @selected_grade_schema ||=
        if current_qualification.selected_grade_schema_id.present?
          current_grade_schemas.find do |schema|
            schema.id == current_qualification.selected_grade_schema_id
          end
        elsif current_grade_schemas.one?
          current_grade_schemas.first
        end
    end

    def selected_equivalent_qualification
      return if current_qualification.non_uk_qualification_type.blank? || finder.blank?

      finder.equivalent_qualifications.find do |qualification|
        qualification.name == current_qualification.non_uk_qualification_type
      end
    end

    def current_grade_schemas
      selected_equivalent_qualification&.grade_schemas || []
    end

    def requires_grade_schema_selection?
      current_grade_schemas.many? ||
        current_grade_schemas.any? { |schema| schema.description == 'Percentage' }
    end

    def selected_grade_schema_percentage?
      selected_grade_schema&.description == 'Percentage'
    end

    def finder
      return if @institution_country.blank?

      @finder ||= InternationalQualifications::StructuredGcseOptionFinder.new(@institution_country, @subject)
    end

    def redirect_if_feature_flag_inactive
      return if FeatureFlag.active?('2027_international_qualifications_flow')

      redirect_to root_path
    end

    def subject_param
      params.require(:subject)
    end
  end
end
