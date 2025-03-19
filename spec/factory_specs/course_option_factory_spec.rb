require 'rails_helper'

RSpec.describe 'CourseOption factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:traits) { [] }
  let(:attributes) { {} }

  factory :course_option do
    describe 'transient `recruitment_cycle_year`' do
      let(:attributes) { { recruitment_cycle_year: 2020 } }

      it 'sets the recruitment cycle year on the course' do
        expect(record.course.recruitment_cycle_year).to eq(2020)
      end
    end

    it 'associates a site with the same provider as the course' do
      expect(record.site.provider).to eq(record.course.provider)
    end

    field :vacancy_status, value: 'vacancies'
    field :site_still_valid, value: true

    trait :with_course_uuid do
      it 'associates a course with a UUID' do
        expect(record.course.uuid).to be_present
      end

      describe 'transient `recruitment_cycle_year`' do
        let(:attributes) { { recruitment_cycle_year: 2020 } }

        it 'sets the recruitment cycle year on the course' do
          expect(record.course.recruitment_cycle_year).to eq(2020)
        end
      end
    end

    trait :full_time do
      field :study_mode, value: 'full_time'
    end

    trait :part_time do
      field :study_mode, value: 'part_time'
    end

    trait :no_vacancies do
      field :vacancy_status, value: 'no_vacancies'
    end

    trait :previous_year do
      it 'associates a course from the previous year' do
        expect(record.course.recruitment_cycle_year).to eq(previous_year)
      end
    end

    trait :previous_year_but_still_available do
      it_behaves_like 'trait :previous_year'

      it 'creates a new course option for the same course as the previous year' do
        expect { record }.to change { CourseOption.count }.by(2)
        expect(CourseOption.count).to eq(2)

        previous_year_option = CourseOption.first
        expect(previous_year_option.course.recruitment_cycle_year).to eq(previous_year)
        expect(record).to eq(previous_year_option)

        current_year_option = CourseOption.last
        expect(current_year_option.course.recruitment_cycle_year).to eq(current_year)
        expect(current_year_option.site.code).to eq(previous_year_option.site.code)
      end
    end

    trait :available_in_current_and_next_year do
      it 'associates a course from the current year' do
        expect(record.course.recruitment_cycle_year).to eq(current_year)
      end

      it 'creates a new next-year course option for the same course as this year' do
        expect { record }.to change { CourseOption.count }.by(2)
        expect(CourseOption.count).to eq(2)

        current_year_option = CourseOption.first
        expect(current_year_option.course.recruitment_cycle_year).to eq(current_year)
        expect(record).to eq(current_year_option)

        next_year_option = CourseOption.last
        expect(next_year_option.course.recruitment_cycle_year).to eq(next_year)
        expect(next_year_option.site.code).to eq(current_year_option.site.code)
      end
    end
  end
end
