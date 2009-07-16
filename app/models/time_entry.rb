class TimeEntry < ActiveRecord::Base
      
  belongs_to :user
  belongs_to :activity
  
  validates_numericality_of :hours, :greater_than_or_equal_to => 0.0, :less_than_or_equal_to => 24.0
  validates_format_of :hours, :with => /^[\d|.|,]*$/
  validate_on_update :must_not_be_locked
  
  named_scope :on_day, lambda { |day|
    {  :conditions => ['date = ?', day ] }
  }

  named_scope :for_user, lambda { |user_id|
    { :conditions => { :user_id => user_id } }
  }

  named_scope :unbilled, 
     :conditions => { :billed => false } 

  named_scope :between, lambda { |*args|
    {  :conditions => ['date between ? and ?', args.first, args.second] }
  }
      
  named_scope :for_activity, lambda { |activity_id|
    { :conditions => { :activity_id => activity_id } }
  }
  
  def <=>(other)
    date <=> other.date
  end

  def to_s
    "#{self.hours} hours on date #{self.date}"
  end

  def hours_to_s
    if self.hours > 0 then self.hours.to_s else '-' end
  end
  private
  
  def must_not_be_locked
    if changed?
      errors.add_to_base("Updating locked time entries is not possible") if locked
    end
  end
  
end