USE "${db_name}";

CREATE TABLE "${table_name}" (
  id INT NOT NULL AUTO_INCREMENT,
  email VARCHAR(50) NOT NULL,
  PRIMARY KEY (id)
);
