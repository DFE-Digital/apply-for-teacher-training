class DisplayCourseLength
  def self.call(course_length:)
    case course_length
    when 'OneYear'
      '1 year'
    when 'TwoYears'
      'Up to 2 years'
    else
      course_length
    end
  end
end
