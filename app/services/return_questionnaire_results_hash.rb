class ReturnQuestionnaireResultsHash
  def self.call(params:)
    safe_to_work_with_children_explanation = params['safe_to_work_with_children_explanation'] if params['safe_to_work_with_children'] == 'false'
    consent_to_be_contacted_details = params['consent_to_be_contacted_details'] if params['consent_to_be_contacted'] == 'true'

    {
      'experience_rating' => params['experience_rating'],
      'experience_explanation' => params["experience_explanation_#{params['experience_rating']}"],
      'guidance_rating' => params['guidance_rating'],
      'guidance_explanation' =>  params["guidance_explanation_#{params['guidance_rating']}"],
      'safe_to_work_with_children' =>  params['safe_to_work_with_children'],
      'safe_to_work_with_children_explanation' => safe_to_work_with_children_explanation,
      'consent_to_be_contacted' => params['consent_to_be_contacted'],
      'consent_to_be_contacted_details' => consent_to_be_contacted_details,
    }
  end
end
