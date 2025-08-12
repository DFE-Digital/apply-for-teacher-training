module CandidateInterface::Degrees::FormConstants
  VALID_STEPS = [
    'country', # Everyone selects a country
    'degree_level', # Only UK and countries with UK-compatible degrees select a level (eg Bachelor's or Master's)
    'type', # Everyone selects a type, if UK or compatible degree level, something like 'Bachelor. of Science'. Free text if other international. In some cases, the type is entered on the level step (ie, Level 6 Diploma is selected at level, but it's actually a type. And if you select 'other' on the level step, the other_level option becomes the type)
    'subject', # Everyone selects a subject
    'completed', # Everyone says if they have completed their degree
    'grade', # If the degree is a doctorate, they skip this question
    'start_year', # Everyone enters a start year
    'award_year', # Everyone enters an award year, even if it is in the future
    'university', # Everyone selects a university.
    'enic', # All international degrees if completed, even UK-compatible ones get this question
    'enic_reference', # Only international degrees when they say they have received an enic.
  ].freeze

  YES = 'Yes'.freeze
  NO = 'No'.freeze
  OTHER_GRADE = 'Other'.freeze

  UK_BACHELORS_DEGREE_GRADES = [
    'First-class honours',
    'Upper second-class honours (2:1)',
    'Lower second-class honours (2:2)',
    'Third-class honours',
    'Pass',
    'Other',
  ].freeze

  UK_MASTERS_DEGREE_GRADES = %w[Distinction Merit Pass Other].freeze
  NOT_APPLICABLE = 'N/A'.freeze
  UNKNOWN = 'Unknown'.freeze
  I_DO_NOT_KNOW = 'I do not know'.freeze
  QUALIFICATION_LEVEL = {
    'foundation' => 'Foundation degree',
    'bachelor' => 'Bachelor’s degree',
    'master' => 'Master’s degree',
    'doctor' => 'Doctorate (PhD)',
  }.freeze
end
