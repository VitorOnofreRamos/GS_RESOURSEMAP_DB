-- Drop Project Tables
DROP TABLE GS_needs cascade constraints;
DROP TABLE GS_donations cascade constraints;
DROP TABLE GS_users cascade constraints;
DROP TABLE GS_organizations cascade constraints;
DROP TABLE GS_categories cascade constraints;
DROP TABLE GS_regions cascade constraints;
DROP TABLE GS_auditoria cascade constraints;

-- Drop Project sequences
DROP SEQUENCE seq_needs;
DROP SEQUENCE seq_donations;
DROP SEQUENCE seq_users;
DROP SEQUENCE seq_organizations;
DROP SEQUENCE seq_categories;
DROP SEQUENCE seq_regions;
DROP SEQUENCE seq_auditoria;

-- Create Project Sequences
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_organizations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_donations START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_needs START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_categories START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_regions START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_auditoria START WITH 1 INCREMENT BY 1;

-- Create Project Tables
CREATE TABLE GS_regions (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(255) NOT NULL,
  state VARCHAR2(100) NOT NULL,
  country VARCHAR2(100) NOT NULL,
  latitude NUMBER(10,8) NOT NULL, -- Coordenadas para mapas
  longitude NUMBER(11,8) NOT NULL -- Coordenadas para mapas
);

CREATE TABLE GS_categories (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(100) UNIQUE NOT NULL,
  description CLOB,
  icon VARCHAR2(50), -- Classe CSS para ícones (ex: 'fas fa-apple-alt')
  color VARCHAR2(7) -- Código hexadecimal da cor (ex: '#28a75')
);

CREATE TABLE GS_organizations (
  id NUMBER PRIMARY KEY,
  name VARCHAR2(255) NOT NULL,
  description CLOB,
  email VARCHAR2(255) UNIQUE NOT NULL,
  phone VARCHAR2(20) NOT NULL,
  address CLOB NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  region_id NUMBER NOT NULL, -- FK para regions
  CONSTRAINT fk_organizations_region FOREIGN KEY (region_id) REFERENCES GS_regions(id)
);

CREATE TABLE GS_users (
  id NUMBER PRIMARY KEY,
  email VARCHAR2(255) UNIQUE NOT NULL,
  name VARCHAR2(255) NOT NULL,
  provider VARCHAR2(50),
  provider_id VARCHAR2(255),
  role VARCHAR2(20) DEFAULT 'USER' NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  organization_id NUMBER NOT NULL, -- FK para organizations
  CONSTRAINT chk_users_role CHECK (role IN ('USER', 'ADMIN', 'ORGANIZATION')),
  CONSTRAINT fk_users_organization FOREIGN KEY (organization_id) REFERENCES GS_organizations(id)
);

CREATE TABLE GS_donations (
  id NUMBER PRIMARY KEY,
  title VARCHAR2(255) NOT NULL,
  description CLOB,
  quantity NUMBER NOT NULL,
  status VARCHAR2(20) DEFAULT 'AVAILABLE' NOT NULL,
  contact_info VARCHAR2(255),
  expiry_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  user_id NUMBER NOT NULL, -- FK para users
  category_id NUMBER, -- FK para categories
  region_id NUMBER NOT NULL, -- FK para regions
  CONSTRAINT chk_donations_quantity CHECK (quantity > 0),
  CONSTRAINT chk_donations_status CHECK (status IN ('AVAILABLE', 'RESERVED', 'DELIVERED', 'EXPIRED')),
  CONSTRAINT fk_donations_user FOREIGN KEY (user_id) REFERENCES GS_users(id),
  CONSTRAINT fk_donations_category FOREIGN KEY (category_id) REFERENCES GS_categories(id),
  CONSTRAINT fk_donations_region FOREIGN KEY (region_id) REFERENCES GS_regions(id)
);

CREATE TABLE GS_needs (
  id NUMBER PRIMARY KEY,
  title VARCHAR2(255) NOT NULL,
  description CLOB,
  quantity NUMBER NOT NULL,
  priority VARCHAR2(20) DEFAULT 'MEDIUM' NOT NULL,
  status VARCHAR2(20) DEFAULT 'ACTIVE' NOT NULL,
  deadline TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  organization_id NUMBER NOT NULL, -- FK para organizations
  category_id NUMBER, -- FK para categories
  region_id NUMBER NOT NULL, -- FK para regions
  CONSTRAINT chk_needs_quantity CHECK (quantity > 0),
  CONSTRAINT chk_needs_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
  CONSTRAINT chk_needs_status CHECK (status IN ('ACTIVE', 'FULFILLED', 'CANCELLED')),
  CONSTRAINT fk_needs_organization FOREIGN KEY (organization_id) REFERENCES GS_organizations(id),
  CONSTRAINT fk_needs_category FOREIGN KEY (category_id) REFERENCES GS_categories(id),
  CONSTRAINT fk_needs_region FOREIGN KEY (region_id) REFERENCES GS_regions(id)
);

CREATE TABLE GS_auditoria(
  id NUMBER PRIMARY KEY,
  table_name VARCHAR (50) NOT NULL,
  register_id NUMBER NOT NULL,
  operation_type VARCHAR(10) NOT NULL,
  date_time TIMESTAMP NOT NULL,
  db_user VARCHAR2(50) NOT NULL,
  old_data CLOB,
  new_data CLOB,
  CONSTRAINT chk_auditoria_opration_type CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE'))
);