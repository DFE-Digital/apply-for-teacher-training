require 'rails_helper'

RSpec.describe DataMigrations::PruneQualificationFlipFlopsFromCourseAudits, with_audited: true do
  let(:first_course) { create(:course) }
  let(:course_with_flip_flops) { create(:course) }
  let(:other_course) { create(:course) }

  it 'preserves most recent qualification change per type' do
    Audited.audit_class.as_user('(Automated process)') do
      first_course.update(qualifications: %w[qts pgce])

      (1..5).each do |i|
        course_with_flip_flops.update(qualifications: %w[qts], audit_comment: i)
        course_with_flip_flops.update(qualifications: nil, audit_comment: i)
        course_with_flip_flops.update(qualifications: %w[qts pgce], audit_comment: i)
        course_with_flip_flops.update(qualifications: nil, audit_comment: i)
      end
      course_with_flip_flops.update(qualifications: %w[qts], audit_comment: 'final')

      other_course.update(qualifications: %w[qts])
    end

    described_class.new.change

    expect(first_course.audits.reload.count).to eq(2)
    expect(first_course.audits.order('created_at').last.audited_changes).to \
      eq({ 'qualifications' => [nil, %w[qts pgce]] })
    expect(other_course.audits.reload.count).to eq(2)
    expect(other_course.audits.order('created_at').last.audited_changes).to \
      eq({ 'qualifications' => [nil, %w[qts]] })

    expect(course_with_flip_flops.audits.reload.count).to eq(5)
    audits = course_with_flip_flops.audits.where(action: 'update').order('created_at')
    expect(audits.map(&:comment)).to eq(%w[5 5 5 final])
    expect(audits.map(&:audited_changes)).to eq([
      { 'qualifications' => [%w[qts], nil] },
      { 'qualifications' => [nil, %w[qts pgce]] },
      { 'qualifications' => [%w[qts pgce], nil] },
      { 'qualifications' => [nil, %w[qts]] },
    ])
  end

  it 'only deletes changes made by (Automated process)' do
    3.times.each do
      course_with_flip_flops.update(qualifications: %w[qts])
      course_with_flip_flops.update(qualifications: nil)
    end

    described_class.new.change

    expect(course_with_flip_flops.audits.reload.count).to eq(7)
  end

  it 'ignores events that change other fields as well as qualifications' do
    3.times.each do
      course_with_flip_flops.update(qualifications: %w[qts], withdrawn: true)
      course_with_flip_flops.update(qualifications: nil, withdrawn: false)
    end

    described_class.new.change

    expect(course_with_flip_flops.audits.reload.count).to eq(7)
  end
end
