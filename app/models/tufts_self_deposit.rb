class TuftsSelfDeposit < TuftsPdf
  attr_writer :current_step
  attr_accessor :deposit_attachment
  validates_presence_of :rights, :if => lambda { |o| o.current_step == "deposit_type" }

  def deposit_type
    self.rights
  end

  def deposit_agreement
    @deposit_type = TuftsDepositType.find_by_display_name(deposit_type)
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