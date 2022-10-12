CREATE SCHEMA IF NOT EXISTS custom;

CREATE TABLE custom.operations (
operation_id INT NOT NULL PRIMARY KEY,
account_id INT NOT NULL,
operation_type VARCHAR(1) NOT NULL,
operation_date DATE NOT NULL,
agreement_num VARCHAR(32),
amount INT NOT NULL,
CONSTRAINT operation_type CHECK (operation_type in('D', 'C'))
);

CREATE TABLE custom.org (
org_id INT NOT NULL,
parent_id INT,
dt DATE NOT NULL,
"name" VARCHAR(32) NOT NULL,
tlg VARCHAR(5) NOT NULL,
PRIMARY KEY (org_id, dt)
);

CREATE TABLE custom.summary (
org_id INT NOT NULL,
dt DATE NOT NULL,
amount INT NOT NULL,
PRIMARY KEY (org_id, dt, amount),
FOREIGN KEY (org_id, dt) REFERENCES custom.org (org_id, dt)
);

CREATE INDEX agreement_index ON custom.operations (agreement_num);