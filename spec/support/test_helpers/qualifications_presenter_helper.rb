module QualificationsPresenterHelper
  def qualification_for(presenter, qualification_type, subject_name)
    presenter.qualifications[qualification_type].find do |qualification|
      qualification[:subject] == subject_name
    end
  end
end
