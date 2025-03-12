require 'rails_helper'

RSpec.describe CandidateInterface::ReopenBannerComponent do
  describe '#render' do
    context 'before find reopens', time: after_apply_deadline do
      it 'renders the banner for an app with the correct details' do
        result = render_inline(described_class.new(flash_empty: true))
        timetable = RecruitmentCycleTimetable.current_timetable

        apply_opens_date = timetable.apply_reopens_at.to_fs(:govuk_date)
        academic_year = timetable.academic_year_range_name
        next_academic_year = timetable.relative_next_timetable.academic_year_range_name

        expect(result).to have_content 'The application deadline has passed'
        expect(result).to have_content(
          "The application deadline has passed for courses starting in the #{academic_year} academic year.",
        )
        expect(result)
          .to have_content(
            "From #{apply_opens_date} you will be able to apply for courses starting in the #{next_academic_year} academic year.",
          )
      end

      it 'renders nothing if the flash contains something' do
        result = render_inline(described_class.new(flash_empty: false))

        expect(result.text).to be_blank
      end
    end

    context 'after find opens', time: after_find_opens do
      it 'renders the banner for with the correct details' do
        result = render_inline(described_class.new(flash_empty: true))

        timetable = RecruitmentCycleTimetable.current_timetable

        apply_opens_date = timetable.apply_opens_at.to_fs(:govuk_date)
        academic_year = timetable.cycle_range_name
        next_academic_year = timetable.academic_year_range_name

        expect(result).to have_content 'The application deadline has passed'
        expect(result).to have_content(
          "The application deadline has passed for courses starting in the #{academic_year} academic year.",
        )
        expect(result)
          .to have_content(
            "From #{apply_opens_date} you will be able to apply for courses starting in the #{next_academic_year} academic year.",
          )
      end
    end

    context 'after apply opens', time: after_apply_reopens do
      it 'does not render when we are not between cycles' do
        result = render_inline(described_class.new(flash_empty: true))

        expect(result.text).to be_blank
      end
    end
  end
end
