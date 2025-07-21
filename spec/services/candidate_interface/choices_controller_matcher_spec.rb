require 'rails_helper'

RSpec.describe CandidateInterface::ChoicesControllerMatcher, type: :model do
  describe '.choices_controller?' do
    subject {
      described_class.choices_controller?(
        current_application:,
        controller_path:,
        request:,
      )
    }

    let(:current_application) { instance_double(ApplicationForm, v23?: false) }
    let(:controller_path) { '' }
    let(:request) { instance_double(ActionDispatch::Request, referer: nil) }

    it { is_expected.to be_falsey }

    [
      'candidate_interface/course_choices', # the course choice wizard
      'candidate_interface/application_choices', # controller for Your applications & deleting an application choice
      'candidate_interface/decisions', # withdrawing from a course offer
      'candidate_interface/apply_from_find',

      'candidate_interface/course_choices/do_you_know_which_course',
    ].each do |controller_path_under_test|
      context "when controller path is '#{controller_path_under_test}'" do
        let(:controller_path) { controller_path_under_test }

        it { is_expected.to be_truthy }
      end

      context "when controller path is '#{controller_path_under_test}' and the application is v23" do
        let(:controller_path) { controller_path_under_test }
        let(:current_application) { instance_double(ApplicationForm, v23?: true) }

        it { is_expected.to be_falsey }
      end
    end

    context "when controller path is 'candidate_interface/guidance'" do
      let(:controller_path) { 'candidate_interface/guidance' }

      it { is_expected.to be_falsey }
    end

    context "when controller path is 'candidate_interface/guidance' and referer does not matches 'choices'" do
      let(:controller_path) { 'candidate_interface/guidance' }
      let(:request) { instance_double(ActionDispatch::Request, referer: 'anything') }

      it { is_expected.to be_falsey }
    end

    context "when controller path is 'candidate_interface/guidance' and referer matches 'choices'" do
      let(:controller_path) { 'candidate_interface/guidance' }
      let(:request) { instance_double(ActionDispatch::Request, referer: 'choices') }

      it { is_expected.to be_truthy }
    end
  end

  describe '.invites_controller?' do
    subject {
      described_class.invites_controller?(
        controller_path:,
        request:,
      )
    }

    let(:controller_path) { '' }
    let(:request) { instance_double(ActionDispatch::Request, referer: nil) }

    it { is_expected.to be_falsey }

    [
      'candidate_interface/share_details',
      'candidate_interface/pool_opt_ins',
      'candidate_interface/draft_preferences',
      'candidate_interface/dynamic_location_preferences',
      'candidate_interface/training_locations',
      'candidate_interface/location_preferences',
      'candidate_interface/publish_preferences',
      'candidate_interface/funding_type',
      'candidate_interface/invites',
    ].each do |controller_path_under_test|
      context "when controller path is '#{controller_path_under_test}'" do
        let(:controller_path) { controller_path_under_test }

        it { is_expected.to be_truthy }
      end
    end
  end
end
