class FindInterface::SubjectArea < FindInterface::Base
  has_many :subjects, foreign_key: :type, inverse_of: :subject_area
  self.primary_key = :typename
end
