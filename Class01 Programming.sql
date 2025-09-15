declare @intvariable int
set @intvariable = 78
print @intvariable

select @intvariable = 42
print @intvariable

select @intvariable = count(*) from track
print 'There are '+cast(@intvariable as varchar(20))+' tracks in the database'

if @intvariable < 4000
	begin	
		print'Purchase some tracks!'
		declare @artistcount int 
		select @artistcount = count(*) from artist
		print @artistcount
	end

declare @i int
set @i = 0
while @i<10
	begin 
		set @i = @i+1
		print @i
	end

DECLARE table1cursor CURSOR FOR select genreid, name from genre

OPEN table1cursor

DECLARE @id int, @name varchar(100)
FETCH NEXT FROM table1cursor INTO @id, @name

WHILE @@FETCH_STATUS = 0
	BEGIN
		print cast(@id as varchar(100))+'. '+@name
		FETCH NEXT FROM table1cursor INTO @id, @name
	END

CLOSE table1cursor
DEALLOCATE table1cursor