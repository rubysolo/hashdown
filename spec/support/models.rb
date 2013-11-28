class State < ActiveRecord::Base
  scope :starting_with_c, -> { where("name like 'C%'") }
  finder :abbreviation
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

class Currency < ActiveRecord::Base
  default_scope { order(:code) }
  selectable
end
