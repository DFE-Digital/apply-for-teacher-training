require 'rails_helper'

RSpec.describe DeferredOfferConfirmation do
  subject(:deferred_offer_confirmation) { described_class.new(provider_user: build(:provider_user), offer: create(:offer)) }

  describe 'associations' do
    it { is_expected.to belong_to(:provider_user) }
    it { is_expected.to belong_to(:offer) }
    it { is_expected.to belong_to(:course).optional }
    it { is_expected.to belong_to(:location).optional.class_name('Site') }
  end

  describe 'enums' do
    it {
      expect(deferred_offer_confirmation).to define_enum_for(:study_mode)
                                               .with_values(
                                                 full_time: 'full_time',
                                                 part_time: 'part_time',
                                               )
                                               .backed_by_column_of_type(:string)
                                               .validating(allowing_nil: true)
                                               .without_instance_methods
                                               .without_scopes
    }

    it {
      expect(deferred_offer_confirmation).to define_enum_for(:conditions_status)
                                               .with_values(
                                                 met: 'met',
                                                 pending: 'pending',
                                               )
                                               .backed_by_column_of_type(:string)
                                               .validating(allowing_nil: true)
                                               .without_instance_methods
                                               .without_scopes
    }
  end

  describe 'delegations' do
    it { is_expected.to delegate_method(:application_choice).to(:offer) }
    it { is_expected.to delegate_method(:conditions).to(:offer) }
    it { is_expected.to delegate_method(:provider).to(:offer) }
    it { is_expected.to delegate_method(:name_and_code).to(:provider).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:name_and_code).to(:course).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:name_and_address).to(:location).with_prefix.allow_nil }
  end

  describe 'after_initialize' do
    it 'is expected to set course_id, site_id and study_mode from the offer if they are nil' do
      course_option = create(:course_option)
      application_choice = create(:application_choice, current_course_option: course_option)
      offer = create(:offer, application_choice:)

      deferred_offer_confirmation = described_class.new(
        provider_user: build(:provider_user),
        offer: offer,
      )

      expect(deferred_offer_confirmation.course_id).to eq(course_option.course.id)
      expect(deferred_offer_confirmation.site_id).to eq(course_option.site.id)
      expect(deferred_offer_confirmation.study_mode).to eq(course_option.study_mode)
    end

    it 'is expected to not override course_id, site_id and study_mode if they are already set' do
      course_option = create(:course_option)
      application_choice = create(:application_choice, current_course_option: course_option)
      offer = create(:offer, application_choice:)

      deferred_offer_confirmation = described_class.new(
        provider_user: build(:provider_user),
        offer: offer,
        course_id: 1,
        site_id: 5,
        study_mode: 'new_value',
      )

      expect(deferred_offer_confirmation.course_id).to be(1)
      expect(deferred_offer_confirmation.site_id).to be(5)
      expect(deferred_offer_confirmation.study_mode).to eq('new_value')
    end

    it 'is expected to not override course_id, site_id and study_mode if any of them are already set' do
      course_option = create(:course_option)
      application_choice = create(:application_choice, current_course_option: course_option)
      offer = create(:offer, application_choice:)

      deferred_offer_confirmation = described_class.new(
        provider_user: build(:provider_user),
        offer: offer,
        course_id: 1,
      )

      expect(deferred_offer_confirmation.course_id).to be(1)
      expect(deferred_offer_confirmation.site_id).to be_nil
      expect(deferred_offer_confirmation.study_mode).to be_nil
    end
  end

  describe 'validations on: :submit' do
    it 'is expected to be valid when all of the fields are in the current cycle' do
      course_option = create(:course_option)
      application_choice = create(:application_choice, current_course_option: course_option)
      offer = create(:offer, application_choice:)

      deferred_offer_confirmation = described_class.new(
        provider_user: build(:provider_user),
        offer: offer,
        course_id: course_option.course.id,
        site_id: course_option.site.id,
        study_mode: course_option.study_mode,
      )

      expect(deferred_offer_confirmation.valid?(:submit)).to be_truthy
      expect(deferred_offer_confirmation.errors).to be_empty
    end

    context 'validating the course is available in the current cycle' do
      it 'is expected to not be valid when the course is in the previous cycle but not in the current cycle' do
        course_option = create(:course_option, :previous_year)
        application_choice = create(:application_choice, current_course_option: course_option)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option.course.id,
          site_id: course_option.site.id,
          study_mode: course_option.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_falsey
        expect(deferred_offer_confirmation.errors.messages).to include(course: include('is not available in the current cycle'))
      end

      it 'is expected to be valid when the course is in the previous cycle and in the current cycle' do
        course_option = create(:course_option, :previous_year_but_still_available)
        application_choice = create(:application_choice, current_course_option: course_option)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option.course.id,
          site_id: course_option.site.id,
          study_mode: course_option.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_truthy
      end
    end

    context 'validating the location is available for the selected course in the current cycle' do
      it 'is expected to not be valid when the location is in the previous cycle but not in the current cycle' do
        course_previous_cycle = create(:course, :previous_year, code: 'AB12')
        course_current_cycle = create(:course, provider: course_previous_cycle.provider, code: 'AB12')
        site_previous_cycle = create(:site, provider: course_previous_cycle.provider)
        course_option_previous_cycle = create(:course_option, study_mode: 'full_time', course: course_previous_cycle, site: site_previous_cycle)
        _course_option_current_cycle = create(:course_option, study_mode: 'full_time', course: course_current_cycle)

        application_choice = create(:application_choice, current_course_option: course_option_previous_cycle)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option_previous_cycle.course.id,
          site_id: course_option_previous_cycle.site.id,
          study_mode: course_option_previous_cycle.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_falsey
        expect(deferred_offer_confirmation.errors.messages).to include(location: include('is not available for this course'))

        expect(deferred_offer_confirmation.errors.messages).not_to include(:course)
        expect(deferred_offer_confirmation.errors.messages).not_to include(:study_mode)
      end

      it 'is expected to be valid when the location is in the previous cycle and in the current cycle' do
        course_previous_cycle = create(:course, :previous_year, code: 'AB12')
        course_current_cycle = create(:course, provider: course_previous_cycle.provider, code: 'AB12')
        site_previous_cycle = create(:site, provider: course_previous_cycle.provider)
        course_option_previous_cycle = create(:course_option, study_mode: 'full_time', course: course_previous_cycle, site: site_previous_cycle)
        _course_option_current_cycle = create(:course_option, study_mode: 'full_time', course: course_current_cycle, site: site_previous_cycle)

        application_choice = create(:application_choice, current_course_option: course_option_previous_cycle)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option_previous_cycle.course.id,
          site_id: course_option_previous_cycle.site.id,
          study_mode: course_option_previous_cycle.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_truthy
      end
    end

    context 'validating the study mode is available for the selected course in the current cycle' do
      it 'is expected to not be valid when the study mode is in the previous cycle but not in the current cycle' do
        course_previous_cycle = create(:course, :previous_year, code: 'AB12')
        course_current_cycle = create(:course, provider: course_previous_cycle.provider, code: 'AB12')
        site_previous_cycle = create(:site, provider: course_previous_cycle.provider)
        course_option_previous_cycle = create(:course_option, study_mode: 'full_time', course: course_previous_cycle, site: site_previous_cycle)
        _course_option_current_cycle = create(:course_option, study_mode: 'part_time', course: course_current_cycle, site: site_previous_cycle)

        application_choice = create(:application_choice, current_course_option: course_option_previous_cycle)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option_previous_cycle.course.id,
          site_id: course_option_previous_cycle.site.id,
          study_mode: course_option_previous_cycle.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_falsey
        expect(deferred_offer_confirmation.errors.messages).to include(study_mode: include('is not available for this course'))

        expect(deferred_offer_confirmation.errors.messages).not_to include(:course)
        expect(deferred_offer_confirmation.errors.messages).not_to include(:location)
      end

      it 'is expected to be valid when the location is in the previous cycle and in the current cycle' do
        course_previous_cycle = create(:course, :previous_year, code: 'AB12')
        course_current_cycle = create(:course, provider: course_previous_cycle.provider, code: 'AB12')
        site_previous_cycle = create(:site, provider: course_previous_cycle.provider)
        course_option_previous_cycle = create(:course_option, study_mode: 'full_time', course: course_previous_cycle, site: site_previous_cycle)
        _course_option_current_cycle = create(:course_option, study_mode: 'full_time', course: course_current_cycle, site: site_previous_cycle)

        application_choice = create(:application_choice, current_course_option: course_option_previous_cycle)
        offer = create(:offer, application_choice:)

        deferred_offer_confirmation = described_class.new(
          provider_user: build(:provider_user),
          offer: offer,
          course_id: course_option_previous_cycle.course.id,
          site_id: course_option_previous_cycle.site.id,
          study_mode: course_option_previous_cycle.study_mode,
        )

        expect(deferred_offer_confirmation.valid?(:submit)).to be_truthy
      end
    end
  end
end
