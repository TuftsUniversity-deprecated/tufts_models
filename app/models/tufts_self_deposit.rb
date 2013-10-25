class TuftsSelfDeposit < TuftsPdf
  attr_writer :current_step
  attr_accessor :deposit_attachment
  validates_presence_of :rights, :if => lambda { |o| o.current_step == "deposit_type" }

  def deposit_type
    self.rights
  end

  def fletcher_degrees
    return {'MALD' => 'FL001.002', 'LLM' => 'FL001.001', 'MIB' => 'FL001.003'}
  end

  def tufts_departments
    return {
      'UA005.018' => 'Africa and The New World',
      'UA005.037' => 'Biopsychology (interdisciplinary major)',
      'UA005.010' => 'Dept. of Biology',
      'UA005.019' => 'Dept. of Biomedical Engineering',
      'UA005.009' => 'Dept. of Child Development',
      'UA005.040' => 'Dept. of Civil Engineering',
      'UA005.025' => 'Dept. of Classics',
      'UA005.036' => 'Dept. of Computer Science',
      'UA005.026' => 'Dept. of Drama and Dance'
    }
  end

  def deposit_agreement
    @deposit_type = DepositType.find_by_display_name(deposit_type)
    @deposit_type.deposit_agreement
  end

  def current_step
    @current_step || steps.first
  end

  def steps
    %w[deposit_type confirmation]
  end

  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end
end
