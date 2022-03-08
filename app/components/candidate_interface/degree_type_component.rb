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
    @type = type.level
    @wizard = type
  end

  def find_degree_type_options
    DEGREE_TYPES[type]
  end

  def degree_level
    find_degree_type_options.first.split.first
  end

  def map_hint
    {
      'Foundation' => 'Foundation of Engineering (FdEng)',
      'Bachelor' => 'Bachelor of Engineering (BEng)',
      'Master’s' => 'Master of Engineering (MEng)',
      'Doctor' => 'Doctor of Science (DSc)',
    }[degree_level]
  end
end
