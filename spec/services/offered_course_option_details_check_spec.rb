require 'rails_helper'

RSpec.describe OfferedCourseOptionDetailsCheck do
  let(:course_option) { create(:course_option, study_mode: :full_time) }

  it 'is successful when all the provided details correspond to the course option' do
    service = described_class.new(provider_id: course_option.provider.id,
                                  course_id: course_option.course.id,
                                  course_option_id: course_option.id,
                                  study_mode: course_option.study_mode)

    expect { service.validate! }.not_to raise_error
  end

  it 'throws an InvalidProviderError when the provider does not correspond to the course option' do
    provider = create(:provider)
    service = described_class.new(provider_id: provider.id,
                                  course_id: course_option.course.id,
                                  course_option_id: course_option.id,
                                  study_mode: course_option.study_mode)

    expect { service.validate! }.to raise_error(OfferedCourseOptionDetailsCheck::InvalidStateError, 'Invalid provider for CourseOption')
  end

  it 'throws an InvalidCourseError when the course does not correspond to the course option' do
    course = create(:course)
    service = described_class.new(provider_id: course_option.provider.id,
                                  course_id: course.id,
                                  course_option_id: course_option.id,
                                  study_mode: course_option.study_mode)

    expect { service.validate! }.to raise_error(OfferedCourseOptionDetailsCheck::InvalidStateError, 'Invalid course for CourseOption')
  end

  it 'throws an InvalidStudyModeError when the study mode does not correspond to the course option' do
    study_mode = :part_time
    service = described_class.new(provider_id: course_option.provider.id,
                                  course_id: course_option.course.id,
                                  course_option_id: course_option.id,
                                  study_mode: study_mode)

    expect { service.validate! }.to raise_error(OfferedCourseOptionDetailsCheck::InvalidStateError, 'Invalid study mode for CourseOption')
  end
end
