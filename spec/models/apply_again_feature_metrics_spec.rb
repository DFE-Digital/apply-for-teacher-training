require 'rails_helper'

RSpec.describe ApplyAgainFeatureMetrics, with_audited: true do
  subject(:feature_metrics) { described_class.new }

  def create_apply_again_application(
    original_application = create(:completed_application_form)
  )
    apply_again_application_form = DuplicateApplication.new(
      original_application,
      target_phase: 'apply_2',
    ).duplicate

    apply_again_application_form
  end

  def make_offer_for(application_form)
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form,
    )
    ApplicationStateChange.new(application_choice).make_offer!
  end

  def reject(application_form)
    application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form,
    )
    ApplicationStateChange.new(application_choice).reject!
  end

  describe '#success_rate' do
    context 'without any data' do
      it 'returns nil' do
        expect(feature_metrics.success_rate(1.month.ago)).to be_nil
      end
    end

    context 'with apply again applications' do
      it 'returns 0 when there are no successful apply again applications' do
        reject(create_apply_again_application)
        expect(feature_metrics.success_rate(1.month.ago)).to eq(0)
      end

      it 'returns 0.5 when 50% of apply again applications are successful' do
        create_apply_again_application
        reject(create_apply_again_application)
        make_offer_for(create_apply_again_application)
        expect(feature_metrics.success_rate(1.month.ago)).to eq(0.5)
      end

      it 'returns 1.0 when 100% of apply again applications are successful within given time range' do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 20.days) do
          create_apply_again_application
          reject(create_apply_again_application)
        end
        Timecop.freeze(@today - 10.days) do
          make_offer_for(create_apply_again_application)
        end
        Timecop.freeze(@today - 5.days) do
          reject(create_apply_again_application)
        end
        expect(feature_metrics.success_rate(@today - 12.days, @today - 8.days)).to eq(1.0)
        expect(feature_metrics.success_rate(@today - 12.days, @today - 3.days)).to eq(0.5)
        expect(feature_metrics.success_rate(@today - 22.days, @today - 3.days)).to be_within(0.01).of(0.33)
        expect(feature_metrics.success_rate(@today - 50.days, @today - 40.days)).to be_nil
      end
    end
  end

  describe '#formatted_success_rate' do
    context 'without any data' do
      it 'returns n/a' do
        expect(feature_metrics.formatted_success_rate(1.month.ago)).to eq('n/a')
      end
    end

    context 'with apply again applications' do
      it 'returns correctly formatted values within given time ranges' do
        @today = Time.zone.local(2020, 12, 31, 12)
        Timecop.freeze(@today - 20.days) do
          create_apply_again_application
          reject(create_apply_again_application)
        end
        Timecop.freeze(@today - 10.days) do
          make_offer_for(create_apply_again_application)
        end
        Timecop.freeze(@today - 5.days) do
          reject(create_apply_again_application)
        end
        expect(feature_metrics.formatted_success_rate(@today - 12.days, @today - 8.days)).to eq('100%')
        expect(feature_metrics.formatted_success_rate(@today - 12.days, @today - 3.days)).to eq('50%')
        expect(feature_metrics.formatted_success_rate(@today - 22.days, @today - 3.days)).to eq('33.3%')
        expect(feature_metrics.formatted_success_rate(@today - 50.days, @today - 40.days)).to eq('n/a')
      end
    end
  end

  describe '#formatted_change_rate' do
    context 'without any data' do
      it 'returns n/a' do
        expect(feature_metrics.formatted_change_rate(1.month.ago)).to eq('n/a')
      end
    end

    context 'with apply again applications' do
      it 'returns correctly formatted values within given time ranges' do
        @today = Time.zone.local(2021, 3, 10, 12)
        Timecop.freeze(@today - 20.days) do
          apply_again_application_form = create_apply_again_application
          apply_again_application_form.update!(submitted_at: Time.zone.now)
        end
        Timecop.freeze(@today - 5.days) do
          apply_again_application_form = create_apply_again_application
          apply_again_application_form.update!(submitted_at: Time.zone.now, becoming_a_teacher: 'New statement')
        end
        Timecop.freeze(@today) do
          expect(feature_metrics.formatted_change_rate(25.days.ago, 10.days.ago)).to eq('0%')
          expect(feature_metrics.formatted_change_rate(10.days.ago)).to eq('100%')
          expect(feature_metrics.formatted_change_rate(25.days.ago)).to eq('50%')
        end
      end
    end
  end

  describe '#formatted_application_rate' do
    context 'without any data' do
      it 'returns n/a' do
        expect(feature_metrics.formatted_application_rate(1.month.ago)).to eq('n/a')
      end
    end

    context 'with apply again applications' do
      it 'returns correctly formatted values within given time ranges' do
        @today = Time.zone.local(2021, 3, 10, 12)
        Timecop.freeze(@today - 20.days) do
          @application_forms = create_list(:completed_application_form, 3)
          reject(@application_forms[0])
        end
        Timecop.freeze(@today - 10.days) do
          reject(@application_forms[1])
        end
        Timecop.freeze(@today - 5.days) do
          reject(@application_forms[2])
        end
        Timecop.freeze(@today) do
          create_apply_again_application(@application_forms[1])
          create_apply_again_application(@application_forms[2])

          expect(feature_metrics.formatted_application_rate(25.days.ago)).to eq('66.7%')
          expect(feature_metrics.formatted_application_rate(15.days.ago)).to eq('100%')
          expect(feature_metrics.formatted_application_rate(2.days.ago)).to eq('n/a')
        end
      end
    end
  end
end
