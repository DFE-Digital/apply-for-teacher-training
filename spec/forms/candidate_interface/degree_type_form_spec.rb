require 'rails_helper'

RSpec.describe CandidateInterface::DegreeTypeForm do
  let(:degree) do
    form.application_form.application_qualifications.degree.first
  end

  describe '#save' do
    context 'when the description matches an entry in the HESA data' do
      let(:form) do
        described_class.new(
          type_description: 'Doctor of Divinity',
          application_form: create(:application_form),
          uk_degree: 'yes',
        )
      end

      before do
        form.save
      end

      it 'persists both type description and HESA code' do
        expect(form.application_form.application_qualifications.degree.size).to eq 1
        expect(degree.qualification_type).to eq 'Doctor of Divinity'
        expect(degree.qualification_type_hesa_code).to eq '300'
      end

      it 'persists the degree type uuid' do
        expect(degree.degree_type_uuid).to eq '5b6a5652-c197-e711-80d8-005056ac45bb'
      end
    end

    context 'when the description does not match an entry in the HESA data' do
      let(:form) do
        described_class.new(
          type_description: 'Doctor of Rap Battles',
          application_form: create(:application_form),
          uk_degree: 'yes',
        )
      end

      before do
        form.save
      end

      it 'persists type description but no HESA code' do
        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to be_nil
      end

      it 'persists type description but no degree type uuid' do
        expect(degree.degree_type_uuid).to be_nil
      end
    end

    context 'when missing type_description' do
      let(:form) { described_class.new(application_form: build(:application_form), uk_degree: 'yes') }

      it 'returns false and has errors' do
        expect(form.save).to be false
        expect(form.errors.full_messages).to eq ['Type description Enter your degree type']
      end
    end

    context 'when missing application_form' do
      let(:form) { described_class.new(type_description: 'BSc', uk_degree: 'yes') }

      it 'returns false and has errors' do
        expect(form.save).to be false
        expect(form.errors.full_messages).to eq ['Application form is missing']
      end
    end
  end

  describe '#update' do
    context 'when the type description matches an entry in the HESA data' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'BSc',
        )
      end
      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Divinity', uk_degree: 'yes')
      end

      before do
        form.update
      end

      it 'updates the qualification_type and HESA code' do
        expect(degree.qualification_type).to eq 'Doctor of Divinity'
        expect(degree.qualification_type_hesa_code).to eq '300'
      end

      it 'updates the degree type uuid' do
        expect(degree.degree_type_uuid).to eq '5b6a5652-c197-e711-80d8-005056ac45bb'
      end
    end

    context 'when the type description does not match an entry in the HESA data' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'BSc',
        )
      end
      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Rap Battles', uk_degree: 'yes')
      end

      it 'updates the qualification_type' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to be_nil
      end
    end

    context 'when missing type_description' do
      let(:form) { described_class.new(degree: build(:degree_qualification), uk_degree: 'yes') }

      it 'returns false and has errors' do
        expect(form.update).to be false
        expect(form.errors.full_messages).to eq ['Type description Enter your degree type']
      end
    end

    context 'when missing application_form' do
      let(:form) { described_class.new(type_description: 'Doctor of Rap Battles', uk_degree: 'yes') }

      it 'returns false and has errors' do
        expect(form.update).to be false
        expect(form.errors.full_messages).to eq ['Degree is missing']
      end
    end

    context 'when UK degree is selected' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'BSc',
        )
      end

      let(:form) do
        described_class.new(degree: degree, type_description: 'Doctor of Rap Battles', uk_degree: 'yes')
      end

      it 'updates the qualification_type and sets international to false' do
        form.update
        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to be_nil
        expect(degree.international).to be false
      end
    end

    context 'when non-UK degree is selected' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'BSc',
        )
      end

      let(:form) do
        described_class.new(degree: degree, international_type_description: 'Doctor of Rap Battles', uk_degree: 'no')
      end

      it 'updates the qualification_type and sets international to true' do
        form.update

        expect(degree.qualification_type).to eq 'Doctor of Rap Battles'
        expect(degree.qualification_type_hesa_code).to be_nil
        expect(degree.international).to be true
      end
    end

    context 'when the type description is for bachelors degree and current degree is other degree with other grade' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'MSc',
          grade: 'Distinction',
        )
      end
      let(:form) do
        described_class.new(degree: degree, type_description: 'Bachelor of Arts', uk_degree: 'yes')
      end

      it 'updates the type correctly and grade to nil' do
        form.update

        expect(degree.qualification_type).to eq 'Bachelor of Arts'
        expect(degree.grade).to be_nil
      end
    end

    context 'when the type description is for international bachelors degree and current degree is other degree with other grade' do
      let(:degree) do
        build(
          :degree_qualification,
          application_form: build(:application_form),
          qualification_type: 'MSc',
          grade: 'Distinction',
        )
      end
      let(:form) do
        described_class.new(degree: degree, international_type_description: 'Bachelor of Arts', uk_degree: 'no')
      end

      it 'updates the type correctly and does not set grade to nil' do
        form.update

        expect(degree.qualification_type).to eq 'Bachelor of Arts'
        expect(degree.grade).to eq 'Distinction'
      end
    end
  end
end
