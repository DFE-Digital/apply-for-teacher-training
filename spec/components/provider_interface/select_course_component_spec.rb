require 'rails_helper'

RSpec.describe ProviderInterface::SelectCourseComponent do
  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :course_id
    end
  end

  let(:form_object) { FormObjectClass.new(course_id: selected_course.id) }
  let(:courses) { build_stubbed_list(:course, 10) }
  let(:selected_course) { courses.sample }

  let(:render) do
    render_inline(described_class.new(form_object: form_object,
                                      form_path: '',
                                      courses: courses))
  end

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  it 'renders all courses' do
    expect(render.css('.govuk-radios__item').length).to eq(courses.count)
  end

  it 'selects the preselected course' do
    expect(render.css('.govuk-radios__item input[checked]').first.next_element.text)
      .to eq(selected_course.name_and_code)
  end
end
