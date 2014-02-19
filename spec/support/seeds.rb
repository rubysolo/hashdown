class ActiveRecord::Base
  def self.seed(data_table)
    data_table = data_table.strip.split(/\s*\n\s*/)
    data_table.reject!{|row| row =~ /---/ }

    headers = data_table.shift.split(/\s*\|\s*/)[1..-1]

    delete_all

    data_table.each do |row|
      data = Hash[*headers.zip(row.split(/\s*\|\s*/)[1..-1]).flatten].with_indifferent_access
      if data[primary_key]
        columns, values = data.each_with_object([[], []]) do |(c,v), (cols, vals)|
          cols << connection.quote_column_name(c)
          vals << connection.quote(v)
        end
        connection.execute("INSERT INTO #{table_name} (#{ columns * ', ' }) VALUES (#{ values * ', ' })")
      else
        create(data)
      end
    end
  end
end

State.seed %q{
  +----+--------------+------------+
  | id | abbreviation | name       |
  +----+--------------+------------+
  |  1 | AZ           | Arizona    |
  |  2 | NY           | New York   |
  |  3 | CA           | California |
  |  4 | TX           | Texas      |
  |  5 | CO           | Colorado   |
  +----+--------------+------------+
}

City.seed %q{
  +----------+------------+
  | state_id | name       |
  +----------+------------+
  |        5 | Denver     |
  |        4 | Dallas     |
  +----------+------------+
}

Currency.seed %q{
  +------+----------------+
  | code | name           |
  +------+----------------+
  | GBP  | Pound Sterling |
  | EUR  | Euro           |
  | USD  | US Dollar      |
  | CNY  | Renminbi       |
  +------+----------------+
}
