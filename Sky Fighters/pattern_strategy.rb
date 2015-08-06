#Pattern strategy
OutputStrategy = interface {required_methods :use}

class JsonOut
  def use(file_name, array)
    start = Time.now
    begin
      j = File.open(file_name, 'w')
    rescue IOError
      return p 'I/O error!'
    rescue
      return p 'Oops :('
    end
    array.each{|x|
      j.write({ 'name'=> x.name, 'type' => x.type, 'nation' => x.nation, 'epoch' => x.epoch}.to_json)
    }
    j.close
    time = (Time.now - start).to_i
    p "Export to JSON: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class CsvOut
  def use(file_name, array)
    start = Time.now
    begin
      f = File.open(file_name, 'w')
      f.write("Name,Type,Nation,Epoch\n")
    rescue IOError
      return p 'I/O error!'
    rescue
      return p 'Oops :('
    end
    array.each do |x|
      x.name.gsub!('"', '""')
      f.write("\"#{x.name}\",\"#{x.type}\",\"#{x.nation}\",\"#{x.epoch}\"\n")
    end
    f.close
    time = (Time.now - start).to_i
    p "Export to CSV: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class PostgresqlOut

  def use(database_name, array)
    start = Time.now
    postgre_out = PostgresDirect.new
    postgre_out.connect(database_name)
    begin
      postgre_out.new_table
      postgre_out.clear_table
      postgre_out.query(array)
    rescue Exception => e
      p e.message
    ensure
      postgre_out.disconnect
    end
    time = (Time.now - start).to_i
    p "Export to PostgreSQL: committed #{array.size} records in #{time} seconds"
  end
  implements OutputStrategy
end

class Output
  attr_accessor :output_strategy
  def initialize (output_strategy)
    @output_strategy = output_strategy
  end

  def use_strategy(file_name, array)
    output_strategy.use(file_name, array)
  end
end