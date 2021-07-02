create database socioboard;
create user socioboard@localhost identified by 'Socioboard';
grant all privileges on *.* to socioboard@localhost;
flush privileges;