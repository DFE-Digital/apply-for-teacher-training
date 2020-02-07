module RefereeInterface
  class ReferenceQuestionnaireForm
    include ActiveModel::Model

    attr_reader :reference, :parameters

    def initialize(reference:, parameters:)
      @reference = reference
      @parameters = parameters
    end

    def extract_parameters
      safe_to_work_with_children_explanation = @parameters['safe_to_work_with_children_explanation'] if @parameters['safe_to_work_with_children'] == 'false'
      consent_to_be_contacted_details = @parameters['consent_to_be_contacted_details'] if @parameters['consent_to_be_contacted'] == 'true'

      {
        'experience_rating' => @parameters['experience_rating'],
        'experience_explanation' => @parameters["experience_explanation_#{@parameters['experience_rating']}"],
        'guidance_rating' => @parameters['guidance_rating'],
        'guidance_explanation' =>  @parameters["guidance_explanation_#{@parameters['guidance_rating']}"],
        'safe_to_work_with_children' =>  @parameters['safe_to_work_with_children'],
        'safe_to_work_with_children_explanation' => safe_to_work_with_children_explanation,
        'consent_to_be_contacted' => @parameters['consent_to_be_contacted'],
        'consent_to_be_contacted_details' => consent_to_be_contacted_details,
      }
    end

    def save
      reference.update!(questionnaire: extract_parameters, consent_to_be_contacted: @parameters['consent_to_be_contacted'])
    end
  end
end
