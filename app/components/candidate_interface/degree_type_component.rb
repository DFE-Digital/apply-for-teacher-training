class CandidateInterface::DegreeTypeComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :type, :wizard

  DEGREE_TYPES = {
    'Foundation degree' => [
      'Foundation of Arts (FdA)',
      'Foundation Degree of Education (FDEd)',
      'Foundation of Sciences (FdSs)',
    ],
    'Bachelor degree' => [
      'Bachelor of Arts (BA)',
      'Bachelor of Engineering (BEng)',
      'Bachelor of Science (BSc)',
      'Bachelor of Education (BEd)',
    ],
    'Master’s degree' => [
      'Master of Arts (MA)',
      'Master of Science (MSc)',
      'Master of Education (MEd)',
      'Master of Engineering (MEng)',
    ],
    'Doctorate (PhD)' => [
      'Doctor of Philosophy (PhD)',
      'Doctor of Education (EdD)',
    ],
  }.freeze

  def initialize(type:)
    @type = type.degree_level
    @wizard = type
  end

  def find_degree_type_options
    DEGREE_TYPES[type]
  end

  def degree_level
    find_degree_type_options.first.split.first.downcase
  end

  def dynamic_types
    return 'doctorate' if type == 'Doctorate (PhD)'

    type.downcase
  end

  def map_hint
    {
      'foundation' => 'Foundation of Engineering (FdEng)',
      'bachelor' => 'Bachelor of Engineering (BEng)',
      'master’s' => 'Master of Engineering (MEng)',
      'doctor' => 'Doctor of Science (DSc)',
    }[degree_level]
  end
end
