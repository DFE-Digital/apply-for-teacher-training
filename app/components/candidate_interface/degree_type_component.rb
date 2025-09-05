class CandidateInterface::DegreeTypeComponent < ApplicationComponent
  include ViewHelper
  include Rails.application.routes.url_helpers

  attr_reader :degree_level, :model
  delegate :structured_degree_data?, to: :model

  DEGREE_TYPES = {
    'Foundation degree' => %w[
      7022c4c2-ec9a-4eec-98dc-315bfeb1ef3a
      2b5b8af4-cade-421b-9e3d-026f71f143b7
      a02be347-1d5b-485a-a845-40c2d4b6ee8f
    ],
    'Bachelor’s degree' => %w[
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

  def initialize(model:)
    @degree_level = model.degree_level
    @model = model
  end

  def find_degree_type_options
    name = {
      foundation: 'Foundation degree',
      bachelor: 'Bachelor’s degree',
      master: 'Master’s degree',
      doctor: 'Doctorate (PhD)',
    }[degree_level.to_sym]
    self.class.degree_types[name]
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

  def show_structured_degree_types?
    structured_degree_data?
  end
end
