require 'rails_helper'

RSpec.describe CandidateInterface::ApplicationFormCourseChoicesComponent do
  context 'completed: true' do
    let(:completed) { true }

    context 'choices present' do
      let(:result) do
        render_inline(
          described_class.new(choices_are_present: true, completed: completed),
        )
      end

      it 'renders expected content' do
        expect(heading(result)).to eq 'Course choices'
        expect(link_text(result)).to eq 'Course choices'
        expect(href(result)).to eq '/candidate/application/courses/review'
        expect(status_text(result)).to eq 'Completed'
        expect(first_paragraph(result)).not_to be_present
      end
    end

    context 'no choices present' do
      let(:result) do
        render_inline(
          described_class.new(choices_are_present: true, completed: completed),
        )
      end

      it 'renders without error' do
        # should render without errors but is not an expected state
        expect { result }.not_to raise_error
      end
    end
  end

  context 'completed: false' do
    let(:completed) { false }

    context 'no choices present' do
      let(:result) do
        render_inline(
          described_class.new(choices_are_present: false, completed: completed),
        )
      end

      it 'renders expected content' do
        expect(heading(result)).to eq 'Course choices'
        expect(link_text(result)).to eq 'Course choices'
        expect(href(result)).to eq '/candidate/application/courses'
        expect(status_text(result)).to eq 'Incomplete'
        expect(first_paragraph(result).text).to eq 'You can apply for up to 3 courses.'
      end
    end

    context 'choices present' do
      let(:result) do
        render_inline(
          described_class.new(choices_are_present: true, completed: completed),
        )
      end

      it 'renders expected content' do
        expect(heading(result)).to eq 'Course choices'
        expect(link_text(result)).to eq 'Course choices'
        expect(href(result)).to eq '/candidate/application/courses'
        expect(status_text(result)).to eq 'Incomplete'
        expect(first_paragraph(result)).not_to be_present
      end
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
