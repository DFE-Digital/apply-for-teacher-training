require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormCourseChoiceComponent do
  context 'completed: true' do
    it 'renders successfully' do
      result = render_inline(
        described_class.new(completed: true),
      )

      expect(heading(result)).to eq 'Course'
      expect(link_text(result)).to eq 'Choose your course'
      expect(href(result)).to eq '/candidate/application/review'
      expect(status_text(result)).to eq 'Completed'
    end
  end

  context 'completed: false' do
    let(:result) do
      render_inline(
        described_class.new(completed: false),
      )
    end

    it 'renders successfully' do
      expect(heading(result)).to eq 'Course'
      expect(link_text(result)).to eq 'Choose your course'
      expect(href(result)).to eq '/candidate/application/courses'
      expect(status_text(result)).to eq 'Incomplete'
    end
  end

private

  def heading(result)
    result.css('h2').text.strip
  end

  def link_text(result)
    result.css('a').first.text
  end

  def href(result)
    result.css('a').first.attributes['href'].value
  end

  def status_text(result)
    result.css('.govuk-tag').first.text.strip
  end
end
