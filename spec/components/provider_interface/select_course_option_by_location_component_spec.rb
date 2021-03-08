require 'rails_helper'

RSpec.describe ProviderInterface::SelectCourseOptionByLocationComponent do
  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :course_option_id
    end
  end

  let(:form_object) { FormObjectClass.new(course_option_id: selected_course_option.id) }
  let(:course_options) { build_stubbed_list(:course_option, 10) }
  let(:selected_course_option) { course_options.sample }

  let(:render) do
    render_inline(described_class.new(form_object: form_object,
                                      form_path: '',
                                      course_options: course_options))
  end

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  it 'renders all course_options' do
    expect(render.css('.govuk-radios__item').length).to eq(course_options.count)
  end

  it 'selects the preselected course_option by location' do
    expect(render.css('.govuk-radios__item input[checked]').first.next_element.text)
      .to eq(selected_course_option.site.name)
  end
end
