# Sections

1. Approach hard coded sections

class EditableSections
  EDITABLE_SECTIONS = {
    'candidate_interface/personal_details' => {},
    'candidate_interface/contact_details' => {},
    'candidate_interface/gsce/review' => { conditions: { subject: 'science' } } },
  }

  def initialize(application_form:, controller_path:, action:, params: {})
  end

  def can_edit?
    # this handles all non continuous applications and continuous applications?
    return true if all_applications_unsubmitted?

    # EDITABLE_SECTIONS[controller_path]
    # ...
  end
end

views / components

Makes  CandidateInterface::CompleteSectionComponent to use editable params that
calls the EditableSections class

Also uses the same to not render the change links on the review pages of
sections

if this_section_is_editable?
  show the section complete
else
  show the contact support content
end

controllers

Uses the same to not render the change

But we need how to add the filter:

1. Having the filter in Candidate interface controller might result in a problem
because there are paths and actions not related to the sections (example: your
applications tab, responding to an offer, accepting an offer, post offer
dashboard)
2. Add a mixin and include them in Base controllers as much as possible and
and add to the ones that doesn't contain base controllers
3. Create a SectionController and inherit all base controllers and etc (problem more inheritance)

before filters that if
the candidate submitted and the they trying to go mannually and edit we should
redirect (maybe checking for the section name && the action name because we
should allow the show action for all sections)

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
CandidateInterface::Gcse::ReviewController#edit as HTML
Parameters: {"subject"=>"maths"}

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

## Edge cases

* Adding references after accepting an offer should not have any filter to
    app/controllers/candidate_interface/references/accept_offer/
    editable sections

* Science GSCE
    We might need to the normal checks BUT also the params[:subject]
