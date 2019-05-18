CREATE USER 'monitor'@'%' IDENTIFIED BY 'password';
GRANT SELECT on sys.* to 'monitor'@'%';
FLUSH PRIVILEGES;

CREATE USER 'abyan'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES on user.* to 'abyan'@'%';
FLUSH PRIVILEGES;