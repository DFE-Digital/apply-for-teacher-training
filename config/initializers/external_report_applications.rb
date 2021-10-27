module ExternalReportApplications
  COURSE_TYPES = [
    'Higher education',
    'Postgraduate teaching apprenticeship',
    'School-centred initial teacher training (SCITT)',
    'School Direct (fee-paying)',
    'School Direct (salaried)',
  ].freeze

  PRIMARY_AGE_GROUP = 'Primary'.freeze

  SECONDARY_AGE_GROUP = 'Secondary'.freeze

  FURTHER_EDUCATION_AGE_GROUP = 'Further education'.freeze

  PRIMARY_SUBJECTS = [
    'Primary',
    'Primary with English',
    'Primary with geography and history',
    'Primary with mathematics',
    'Primary with modern languages',
    'Primary with physical education',
    'Primary with science',
  ].freeze

  SECONDARY_SUBJECTS = [
    'Art, or Art and design',
    'Biology',
    'Business studies',
    'Chemistry',
    'Citizenship',
    'Classics',
    'Communication and media studies',
    'Computing',
    'Dance',
    'Design and technology',
    'Drama',
    'Economics',
    'English',
    'English as a second or other language',
    'Geography',
    'Health and social care',
    'History',
    'Mathematics',
    'Modern Languages',
    'Music',
    'Philosophy',
    'Physical education',
    'Physics',
    'Psychology',
    'Religious education',
    'Science',
    'Social sciences',
  ].freeze

  LANGUAGE_SUBJECTS = [
    'French',
    'German',
    'Mandarin',
    'Spanish',
    'Italian',
    'Japanese',
    'Modern languages (other)',
    'Russian',
  ].freeze

  FURTHER_EDUCATION_SUBJECT = 'Further education'.freeze

  PROVIDER_AREAS = [
    'East',
    'East Midlands',
    'London',
    'North East',
    'North West',
    'South East',
    'South West',
    'West Midlands',
    'Yorkshire and The Humber',
  ].freeze

  COURSE_TYPE_MAPPING = {
    'higher_education_programme' => 'Higher education',
    'school_direct_training_programme' => 'School Direct (fee-paying)',
    'school_direct_salaried_training_programme' => 'School Direct (salaried)',
    'scitt_programme' => 'School-centred initial teacher training (SCITT)',
    'pg_teaching_apprenticeship' => 'Postgraduate teaching apprenticeship',
  }.freeze

  AGE_GROUP_MAPPING = {
    'primary' => 'Primary',
    'secondary' => 'Secondary',
    'further_education' => 'Further education',
  }.freeze

  PROVIDER_AREAS_MAPPING = {
    'east_midlands' => 'East Midlands',
    'eastern' => 'East',
    'london' => 'London',
    'north_east' => 'North East',
    'north_west' => 'North West',
    'south_east' => 'South East',
    'south_west' => 'South West',
    'west_midlands' => 'West Midlands',
    'yorkshire_and_the_humber' => 'Yorkshire and The Humber',
  }.freeze

  SUBJECTS_MAPPING = {
    'Art and design' => 'Art, or Art and design',
    'Biology' => 'Biology',
    'Business studies' => 'Business studies',
    'Chemistry' => 'Chemistry',
    'Citizenship' => 'Citizenship',
    'Classics' => 'Classics',
    'Communication and media studies' => 'Communication and media studies',
    'Computing' => 'Computing',
    'Dance' => 'Dance',
    'Design and technology' => 'Design and technology',
    'Drama' => 'Drama',
    'Economics' => 'Economics',
    'English' => 'English',
    'English as a second or other language' => 'English as a second or other language',
    'Further education' => 'Further education',
    'Geography' => 'Geography',
    'Health and social care' => 'Health and social care',
    'History' => 'History',
    'Mathematics' => 'Mathematics',
    'French' => 'Modern Languages',
    'German' => 'Modern Languages',
    'Mandarin' => 'Modern Languages',
    'Spanish' => 'Modern Languages',
    'Italian' => 'Modern Languages',
    'Japanese' => 'Modern Languages',
    'Modern Languages' => 'Modern Languages',
    'Modern languages (other)' => 'Modern Languages',
    'Russian' => 'Modern Languages',
    'Music' => 'Music',
    'Physical education' => 'Physical education',
    'Philosophy' => 'Philosophy',
    'Physics' => 'Physics',
    'Primary' => 'Primary',
    'Primary with English' => 'Primary with English',
    'Primary with geography and history' => 'Primary with geography and history',
    'Primary with mathematics' => 'Primary with mathematics',
    'Primary with modern languages' => 'Primary with modern languages',
    'Primary with physical education' => 'Primary with physical education',
    'Primary with science' => 'Primary with science',
    'Psychology' => 'Psychology',
    'Religious education' => 'Religious education',
    'Science' => 'Science',
    'Social sciences' => 'Social sciences',
  }.freeze
end
