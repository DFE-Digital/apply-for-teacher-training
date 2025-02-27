require 'rails_helper'

RSpec.describe Adviser::TeachingSubject do
  describe 'validations' do
    subject { build(:adviser_teaching_subject) }

    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :external_identifier }
    it { is_expected.to validate_uniqueness_of :external_identifier }

    it {
      expect(subject).to define_enum_for(:level)
                           .backed_by_column_of_type(:string)
                           .with_suffix
                           .with_values(primary: 'primary', secondary: 'secondary')
                           .validating
    }
  end
end
