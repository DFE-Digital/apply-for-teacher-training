# Sections


1. Approach hard coded sections

class or module EditableSections

def initialize(application_form:, controller_name:)
  can :edit, sections: [
    CandidateInterface::PersonalDetails,
    CandidateInterface::ContactDetails,
  ]
  can :edit, section: CandidateInterface::ContactDetails
end

editable_sections = {
  personal_details: CandidateInterface::PersonalDetails,
  contact_information: CandidateInterface::ContactDetails,
}

def can_edit?()
end
end

views / components

if this_section_is_editable?
  show the section complete
else
  show the contact support content
end

controllers

before filters that if
the candidate submitted and the they trying to go mannually and edit we should
redirect (maybe checking for the section name && the action name because we
should allow the show action for all sections)

# Edge case

Science GSCE
We might need to the normal checks BUT also the params[:subject]

## Editable sections

### Personal details

CandidateInterface::PersonalDetails::ReviewController#show
CandidateInterface::PersonalDetails::NameAndDobController#edit
CandidateInterface::PersonalDetails::ReviewController#complete

### Contact information

CandidateInterface::ContactDetails::ReviewController#show
CandidateInterface::ContactDetails::PhoneNumberController#edit
CandidateInterface::ContactDetails::AddressTypeController#edit
CandidateInterface::ContactDetails::AddressController#edit
CandidateInterface::ContactDetails::ReviewController#complete

### Ask for support if you are disabled

CandidateInterface::TrainingWithADisabilityController#show
CandidateInterface::TrainingWithADisabilityController#edit
CandidateInterface::TrainingWithADisabilityController#update
CandidateInterface::TrainingWithADisabilityController#complete

### Interview availability

CandidateInterface::InterviewAvailabilityController#show
CandidateInterface::InterviewAvailabilityController#edit
CandidateInterface::InterviewAvailabilityController#update
CandidateInterface::InterviewAvailabilityController#complete

### Equality and diversity

CandidateInterface::EqualityAndDiversityController#review
CandidateInterface::EqualityAndDiversityController#edit_sex
CandidateInterface::EqualityAndDiversityController#edit_disabilities
CandidateInterface::EqualityAndDiversityController#edit_ethnic_group

### Personal statement

CandidateInterface::PersonalStatementController#show
CandidateInterface::PersonalStatementController#edit
CandidateInterface::PersonalStatementController#complete

## Non editable

### Declare any safeguarding issues

CandidateInterface::SafeguardingController#show
CandidateInterface::SafeguardingController#edit
CandidateInterface::SafeguardingController#complete

### References

CandidateInterface::References::ReviewController#show
CandidateInterface::References::TypeController#new
CandidateInterface::References::NameController#new
CandidateInterface::References::EmailAddressController#new
CandidateInterface::References::RelationshipController#new
CandidateInterface::References::ReviewController#complete

### Unpaid experience

CandidateInterface::Volunteering::ReviewController#show
CandidateInterface::Volunteering::RoleController#edit

### Work history

CandidateInterface::RestructuredWorkHistory::ReviewController#show
CandidateInterface::RestructuredWorkHistory::ReviewController#complete

### Qualifications

#### English GCSE

CandidateInterface::Gcse::ReviewController#show
Parameters: {"subject"=>"english"}

CandidateInterface::Gcse::ReviewController#complete as HTML
Parameters: {"candidate_interface_section_complete_form"=>{"completed"=>"true"}, "subject"=>"english"}

#### Maths GCSE

CandidateInterface::Gcse::ReviewController#show as HTML
Parameters: {"subject"=>"maths"}
CandidateInterface::Gcse::ReviewController#complete as HTML
Parameters: {"candidate_interface_section_complete_form"=>{"completed"=>"true"}, "subject"=>"maths"}

#### Science GCSE

CandidateInterface::Gcse::ReviewController#show as HTML
Parameters: {"subject"=>"science"}
CandidateInterface::Gcse::ReviewController#complete as HTML
Parameters: {"candidate_interface_section_complete_form"=>{"completed"=>"true"}, "subject"=>"science"}

### A levels

CandidateInterface::OtherQualifications::ReviewController#show
CandidateInterface::OtherQualifications::ReviewController#complete

### Degrees

CandidateInterface::Degrees::ReviewController#show
CandidateInterface::Degrees::ReviewController#complete
