class State < ActiveRecord::Base
  scope :starting_with_c, -> { where("name like 'C%'") }
  finder :abbreviation
  has_many :cities
  selectable

  def label
    "#{ abbreviation } (#{ name })"
  end
end

class SortedState < ActiveRecord::Base
  self.table_name = 'states'
  default_scope { order(:abbreviation) }
  finder :abbreviation
end

class StateDefaultNil < ActiveRecord::Base
  self.table_name = 'states'
  finder :abbreviation, default: nil
end

class City < ActiveRecord::Base
  scope :starting_with_d, -> { where("name like 'D%'") }
  belongs_to :state
  selectable
end

class Currency < ActiveRecord::Base
  default_scope { order(:code) }
  selectable
end
