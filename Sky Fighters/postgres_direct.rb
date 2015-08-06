class PostgresDirect

  def connect(database_name)
    @conn = PG.connect(dbname: database_name, host: 'localhost', user: 'planes', password: '123', port: '5432')
  end

  def new_table
    @conn.exec("CREATE TABLE IF NOT EXISTS catalog (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL,
type TEXT,
nation TEXT,
epoch TEXT);")
  end

  def clear_table
    @conn.exec("TRUNCATE catalog;")
  end

  def query(array)
    @conn.transaction do |c|
      array.each do |x|
        c.exec( "INSERT INTO catalog (name, type, nation, epoch)
        VALUES ('#{x.name.gsub("'", "''")}','#{x.type}','#{x.nation.gsub("'", "''")}','#{x.epoch}');")
      end
    end
  end

  def disconnect
    @conn.close
  end
end