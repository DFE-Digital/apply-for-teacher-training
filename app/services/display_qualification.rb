class DisplayQualification
  def self.call(qualification:)
    case qualification
    when 'qts'
      'QTS'
    when 'pgce'
      'PGCE only (without QTS)'
    when 'pgde'
      'PGDE only (without QTS)'
    when 'pgce_with_qts'
      'PGCE with QTS'
    when 'pgde_with_qts'
      'PGDE with QTS'
    end
  end
end
