class CandidateInterface::DegreeTypeComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :type, :wizard

  DEGREE_TYPES = {
    'Foundation degree' => %w[
      7022c4c2-ec9a-4eec-98dc-315bfeb1ef3a
      2b5b8af4-cade-421b-9e3d-026f71f143b7
      a02be347-1d5b-485a-a845-40c2d4b6ee8f
    ],
    'Bachelor degree' => %w[
      db695652-c197-e711-80d8-005056ac45bb
      f7695652-c197-e711-80d8-005056ac45bb
      1b6a5652-c197-e711-80d8-005056ac45bb
      c1695652-c197-e711-80d8-005056ac45bb
    ],
    'Master’s degree' => %w[
      3b6a5652-c197-e711-80d8-005056ac45bb
      456a5652-c197-e711-80d8-005056ac45bb
      4b6a5652-c197-e711-80d8-005056ac45bb
      516a5652-c197-e711-80d8-005056ac45bb
    ],
    'Doctorate (PhD)' => %w[
      676a5652-c197-e711-80d8-005056ac45bb
      656a5652-c197-e711-80d8-005056ac45bb
      03d6b7af-499c-49e3-96cc-e63f9beda6e5
    ],
  }.freeze

  def initialize(type:)
    @type = type.degree_level
    @wizard = type
  end

  def find_degree_type_options
    self.class.degree_types[type]
  end

  def self.reference_data(uuid)
    data = DfE::ReferenceData::Degrees::TYPES.one(uuid)
    { name: data.name, abbreviation: data.abbreviation }
  end

  def name_and_abbr(degree)
    if degree[:name] =~ /\(.*\)$/
      degree[:name]
    else
      "#{degree[:name]} (#{degree[:abbreviation]})"
    end
  end

  def dynamic_types
    return CandidateInterface::DegreeWizard::DOCTORATE if type == CandidateInterface::DegreeWizard::DOCTORATE_LEVEL

    type.downcase
  end

  def self.degree_types
    hash = {}
    DEGREE_TYPES.each do |key, uuid_ary|
      hash[key] = uuid_ary.map { |uuid| reference_data(uuid) }
    end
    hash
  end

  def choose_degree_types(level)
    Hesa::DegreeType.where(level:)
  end

  def map_hint
    {
      'Foundation degree' => 'Foundation of Engineering (FdEng)',
      'Bachelor degree' => 'Bachelor of Engineering (BEng)',
      'Master’s degree' => 'Master of Engineering (MEng)',
      'Doctorate (PhD)' => 'Doctor of Science (DSc)',
    }[type]
  end

  def map_options
    {
      'Foundation degree' => :foundation,
      'Bachelor degree' => :bachelor,
      'Master’s degree' => :master,
      'Doctorate (PhD)' => :doctor,
    }[type]
  end
end
