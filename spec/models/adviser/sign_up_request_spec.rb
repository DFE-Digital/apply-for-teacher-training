require 'rails_helper'

RSpec.describe Adviser::SignUpRequest do
  it { is_expected.to belong_to(:application_form) }
  it { is_expected.to belong_to(:teaching_subject).class_name('Adviser::TeachingSubject') }

  describe '#sent_to_adviser?' do
    context 'when sent_to_adviser_at is present' do
      subject { build(:adviser_sign_up_request, sent_to_adviser_at: Time.zone.now) }

      it { is_expected.to be_sent_to_adviser }
    end

    context 'when sent_to_adviser_at is not present' do
      subject { build(:adviser_sign_up_request, sent_to_adviser_at: nil) }

      it { is_expected.not_to be_sent_to_adviser }
    end
  end

  describe '#sent_to_adviser!' do
    context 'when sent_to_adviser_at is present' do
      let(:adviser_sign_up_request) { build(:adviser_sign_up_request, sent_to_adviser_at: Time.zone.now) }

      it 'does not update sent_to_adviser_at' do
        expect {
          adviser_sign_up_request.sent_to_adviser!
        }.not_to change(adviser_sign_up_request, :sent_to_adviser_at)
      end
    end

    context 'when sent_to_adviser_at is not present' do
      let(:adviser_sign_up_request) { build(:adviser_sign_up_request, sent_to_adviser_at: nil) }

      it 'does sets the sent_to_adviser_at' do
        current_time = Time.zone.now
        expect {
          adviser_sign_up_request.sent_to_adviser!(current_time)
        }.to change(adviser_sign_up_request, :sent_to_adviser_at).from(nil).to(current_time)
      end
    end
  end
end
