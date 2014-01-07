require 'pg'

class PostgresDirect
  # Create the connection instance.
  def connect
    @conn = PG.connect(
        :dbname => 'Picshare',
        :user => 'postgres',
        :password => 'Admin')
  end

  # Prepared statements prevent SQL injection attacks.  However, for the connection, the prepared statements
  # live and apparently cannot be removed, at least not very easily.  There is apparently a significant
  # performance improvement using prepared statements.
  def prepareInsertPictureStatement
    @conn.prepare("insert_picture", "insert into image_store (name, pdesc) values ($1, $2)")
  end
  
  # Add a picture with the prepared statement.
  def executeinsert(path, pdesc)
    @conn.exec_prepared("insert_picture", [path, pdesc])
  end
  
  # Get all images
  def queryImageTable
    @conn.exec( "SELECT name FROM image_store" ) do |result|
      result.each do |row|
        yield row if block_given?
      end
    end
  end

  # Get images by keyword 
  def searchImageTable(search)
    @conn.exec( "SELECT name FROM image_store where position('"+search+"' in pdesc) != 0" ) do |result|
      result.each do |row|
        yield row if block_given?
      end
    end
  end

  # Check user login credentials 
  def valiateUser(uname, upass)
    @conn.exec( "SELECT name FROM user_login where name='#{uname}' and upass='#{upass}'" ) do |result|
      result.each do |row|
        @user = row['name']
      end
    end
	return @user
  end

  def prepareInsertUserStatement(uname, upass)
    @conn.prepare("insert_user", "insert into user_login (name, upass) values ($1, $2)")
	@conn.exec_prepared("insert_user", [uname, upass])
  end

  # Disconnect the back-end connection.
  def disconnect
    @conn.close
  end
end