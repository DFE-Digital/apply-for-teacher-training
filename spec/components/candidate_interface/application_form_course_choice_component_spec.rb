require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormCourseChoiceComponent do
  context 'completed: true' do
    it 'renders successfully' do
      result = render_inline(
        described_class.new(
          choices_are_present: true,
          completed: true,
        ),
      )

      expect(heading(result)).to eq 'Course'
      expect(link_text(result)).to eq 'Choose your course'
      expect(href(result)).to eq '/candidate/application/review'
      expect(status_text(result)).to eq 'Completed'
      expect(first_paragraph(result)).not_to be_present
    end
  end

  context 'completed: false and choice present' do
    let(:result) do
      render_inline(
        described_class.new(
          choices_are_present: true,
          completed: false,
        ),
      )
    end

    it 'renders successfully' do
      expect(heading(result)).to eq 'Course'
      expect(link_text(result)).to eq 'Choose your course'
      expect(href(result)).to eq '/candidate/application/review'
      expect(status_text(result)).to eq 'Incomplete'
      expect(first_paragraph(result)).not_to be_present
    end
  end

  context 'completed: false and no choice addded' do
    let(:result) do
      render_inline(
        described_class.new(
          choices_are_present: false,
          completed: false,
        ),
      )
    end

    it 'renders expected content' do
      expect(heading(result)).to eq 'Course'
      expect(link_text(result)).to eq 'Choose your course'
      expect(href(result)).to eq '/candidate/application/courses/choose'
      expect(status_text(result)).to eq 'Incomplete'
      expect(first_paragraph(result).text).to eq 'You can only apply to 1 course at a time at this stage of your application.'
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

  def first_paragraph(result)
    result.css('p').first
  end
end
