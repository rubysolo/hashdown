class ActiveRecord::Base
  def self.seed(data_table)
    data_table = data_table.strip.split(/\s*\n\s*/)
    data_table.reject!{|row| row =~ /---/ }

    headers = data_table.shift.split(/\s*\|\s*/)[1..-1]

    delete_all

    data_table.each do |row|
      data = Hash[*headers.zip(row.split(/\s*\|\s*/)[1..-1]).flatten].with_indifferent_access
      if data[primary_key]
        connection.execute("INSERT INTO #{table_name} SET #{ data.map{|k,v| "#{ connection.quote_column_name(k) } = #{ connection.quote(v) }" }.join(', ') }")
      else
        create(data)
      end
    end
  end
end

State.seed %q{
  +--------------+------------+
  | abbreviation | name       |
  +--------------+------------+
  | AZ           | Arizona    |
  | NY           | New York   |
  | CA           | California |
  | TX           | Texas      |
  | CO           | Colorado   |
  +--------------+------------+
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
