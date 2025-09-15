drop table if exists #myfirsttable
create table #myfirsttable (Id integer, Name varchar(100))
select * from #myfirsttable
alter table #myfirsttable add Neptun Varchar(6)
select * from #myfirsttable

drop table if exists #myfirsttable
create table #myfirsttable 
(Id integer, 
Name varchar(100))

insert #myfirsttable values (1, 'ABC')
insert #myfirsttable (Id) values (2)

insert #myfirsttable
select genreid,name from Genre
where GenreId > 2

select * from #myfirsttable

drop table if exists #myfirsttable
select * into #myfirsttable
from genre

update #myfirsttable set name = upper(Name)

select * from #myfirsttable
