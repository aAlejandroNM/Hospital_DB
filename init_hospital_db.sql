
CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE person (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  age INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medical_specialty (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE staff (
  id BIGINT PRIMARY KEY,
  specialty_id INT NOT NULL,
  hired_at DATE NULL,
  CONSTRAINT fk_staff_person FOREIGN KEY (id) REFERENCES person(id) ON DELETE CASCADE,
  CONSTRAINT fk_staff_specialty FOREIGN KEY (specialty_id) REFERENCES medical_specialty(id)
);

CREATE TABLE doctor (
  staff_id BIGINT PRIMARY KEY,
  license_code VARCHAR(60) NULL,
  CONSTRAINT fk_doctor_staff FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
);

CREATE TABLE diagnostician (
  staff_id BIGINT PRIMARY KEY,
  certification VARCHAR(120) NULL,
  CONSTRAINT fk_diagnostician_staff FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
);

CREATE TABLE patient (
  id BIGINT PRIMARY KEY,
  insurance_number VARCHAR(80) NULL,
  CONSTRAINT fk_patient_person FOREIGN KEY (id) REFERENCES person(id) ON DELETE CASCADE
);

CREATE TABLE symptom (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL UNIQUE,
  description VARCHAR(500) NULL,
  severity ENUM('MILD','MODERATE','SEVERE','CRITICAL') NOT NULL
);

CREATE TABLE disease (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL UNIQUE,
  description VARCHAR(800) NULL
);

CREATE TABLE disease_symptom (
  disease_id BIGINT NOT NULL,
  symptom_id BIGINT NOT NULL,
  PRIMARY KEY (disease_id, symptom_id),
  CONSTRAINT fk_ds_dis FOREIGN KEY (disease_id) REFERENCES disease(id) ON DELETE CASCADE,
  CONSTRAINT fk_ds_sym FOREIGN KEY (symptom_id) REFERENCES symptom(id) ON DELETE CASCADE
);

CREATE TABLE patient_symptom (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  symptom_id BIGINT NOT NULL,
  noted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ps_pat FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
  CONSTRAINT fk_ps_sym FOREIGN KEY (symptom_id) REFERENCES symptom(id) ON DELETE CASCADE
);

CREATE TABLE medicine (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL UNIQUE,
  quantity INT NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE inventory_movement (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  medicine_id BIGINT NOT NULL,
  change_qty INT NOT NULL,
  reason VARCHAR(200) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_im_med FOREIGN KEY (medicine_id) REFERENCES medicine(id) ON DELETE CASCADE
);

CREATE TABLE medical_document (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  document_type VARCHAR(60) NOT NULL,
  creation_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE medical_record (
  id BIGINT PRIMARY KEY,
  patient_id BIGINT NOT NULL,
  disease_id BIGINT NOT NULL,
  created_by_staff_id BIGINT NULL,
  CONSTRAINT fk_mr_doc FOREIGN KEY (id) REFERENCES medical_document(id) ON DELETE CASCADE,
  CONSTRAINT fk_mr_patient FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
  CONSTRAINT fk_mr_disease FOREIGN KEY (disease_id) REFERENCES disease(id),
  CONSTRAINT fk_mr_staff FOREIGN KEY (created_by_staff_id) REFERENCES staff(id)
);

CREATE TABLE treatment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  disease_id BIGINT NOT NULL,
  name VARCHAR(150) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_treat_patient FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
  CONSTRAINT fk_treat_disease FOREIGN KEY (disease_id) REFERENCES disease(id)
);

CREATE TABLE treatment_medicine (
  treatment_id BIGINT NOT NULL,
  medicine_id BIGINT NOT NULL,
  dosage VARCHAR(120) NULL,
  PRIMARY KEY (treatment_id, medicine_id),
  CONSTRAINT fk_tm_treat FOREIGN KEY (treatment_id) REFERENCES treatment(id) ON DELETE CASCADE,
  CONSTRAINT fk_tm_med FOREIGN KEY (medicine_id) REFERENCES medicine(id)
);

CREATE TABLE treatment_indication (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  treatment_id BIGINT NOT NULL,
  instruction TEXT NOT NULL,
  CONSTRAINT fk_ti_treat FOREIGN KEY (treatment_id) REFERENCES treatment(id) ON DELETE CASCADE
);

CREATE TABLE appointment_status (
  id INT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE appointment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_id BIGINT NOT NULL,
  doctor_id BIGINT NOT NULL,
  date DATETIME NOT NULL,
  status_id INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_app_patient FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
  CONSTRAINT fk_app_doctor FOREIGN KEY (doctor_id) REFERENCES doctor(staff_id),
  CONSTRAINT fk_app_status FOREIGN KEY (status_id) REFERENCES appointment_status(id)
);

CREATE TABLE audit_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  entity VARCHAR(120) NOT NULL,
  action VARCHAR(60) NOT NULL,
  message VARCHAR(1000) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actor_staff_id BIGINT NULL,
  CONSTRAINT fk_audit_staff FOREIGN KEY (actor_staff_id) REFERENCES staff(id)
);

INSERT INTO person (id, name, age) VALUES
(1,'Juan Pérez',34),
(2,'María Gómez',45),
(3,'Pedro Ruiz',50),
(4,'Ana Torres',29),
(5,'Carlos Sánchez',60),
(6,'Lucía Márquez',27),
(7,'Laura Ríos',38),
(8,'Diego López',41);

INSERT INTO medical_specialty (id, name) VALUES
(1,'CARDIOLOGY'),
(2,'PEDIATRICS'),
(3,'NEUROLOGY'),
(4,'ONCOLOGY'),
(5,'GENERAL_MEDICINE'),
(6,'DERMATOLOGY'),
(7,'ORTHOPEDICS');

INSERT INTO staff (id, specialty_id, hired_at) VALUES
(2,5,'2015-03-01'),
(3,3,'2018-07-15'),
(4,5,'2020-01-12'),
(7,1,'2010-05-20'),
(8,6,'2019-11-01');

INSERT INTO doctor (staff_id, license_code) VALUES
(2,'MD-12345'),
(7,'MD-67890');

INSERT INTO diagnostician (staff_id, certification) VALUES
(3,'CERT-2020-1');

INSERT INTO patient (id, insurance_number) VALUES
(1,'INS-100'),
(5,'INS-200'),
(6,'INS-300');

INSERT INTO symptom (id, name, description, severity) VALUES
(1,'Cough','Tos frecuente', 'MODERATE'),
(2,'Fever','Fiebre alta o moderada','MODERATE'),
(3,'Headache','Dolor de cabeza intenso','SEVERE'),
(4,'Rash','Erupción cutánea','MILD'),
(5,'Fatigue','Cansancio extremo','MILD');

INSERT INTO disease (id, name, description) VALUES
(1,'Influenza','Infección respiratoria estacional'),
(2,'COVID-19','Infección por SARS-CoV-2'),
(3,'Migraine','Cefalea arterial severa'),
(4,'Dermatitis','Inflamación de la piel');

INSERT INTO disease_symptom (disease_id, symptom_id) VALUES
(1,1),(1,2),(1,5),
(2,1),(2,2),(2,5),
(3,3),
(4,4);

INSERT INTO patient_symptom (patient_id, symptom_id, noted_at) VALUES
(1,1,'2025-09-20 10:00:00'),
(1,2,'2025-09-20 10:05:00'),
(5,3,'2025-09-18 09:30:00'),
(6,4,'2025-09-19 14:20:00'),
(6,5,'2025-09-19 14:22:00');

INSERT INTO medicine (id, name, quantity) VALUES
(1,'Paracetamol',100),
(2,'Ibuprofen',50),
(3,'Antibiotic X',30),
(4,'Antihistamine Y',75);

INSERT INTO inventory_movement (medicine_id, change_qty, reason) VALUES
(1,-10,'Dispensed to patient 1'),
(2,-5,'Dispensed to patient 5'),
(3,20,'New stock arrival');

INSERT INTO medical_document (id, document_type) VALUES
(1,'Medical Record'),
(2,'Medical Record'),
(3,'Medical Record');

INSERT INTO medical_record (id, patient_id, disease_id, created_by_staff_id) VALUES
(1,1,1,2),
(2,5,3,3),
(3,6,4,8);

INSERT INTO treatment (id, patient_id, disease_id, name) VALUES
(1,1,1,'Flu basic treatment'),
(2,5,3,'Migraine relief'),
(3,6,4,'Dermatitis topical');

INSERT INTO treatment_medicine (treatment_id, medicine_id, dosage) VALUES
(1,1,'500mg every 8h'),
(1,3,'250mg every 12h'),
(2,2,'400mg once if needed'),
(3,4,'Apply topically twice a day');

INSERT INTO treatment_indication (treatment_id, instruction) VALUES
(1,'Rest and hydrate, avoid cold exposure'),
(1,'Follow medication schedule strictly'),
(2,'Dark room, rest, and prescribed analgesic when pain appears'),
(3,'Avoid irritants and apply cream twice daily');

INSERT INTO appointment_status (id, code) VALUES
(1,'PENDING'),
(2,'COMPLETED'),
(3,'CANCELLED'),
(4,'RESCHEDULED');

INSERT INTO appointment (patient_id, doctor_id, date, status_id) VALUES
(1,2,'2025-09-21 09:00:00',2),
(5,7,'2025-09-22 11:30:00',1),
(6,2,'2025-09-23 15:00:00',1),
(1,7,'2025-09-24 08:00:00',4);

INSERT INTO audit_log (entity, action, message, actor_staff_id) VALUES
('patient','CREATE','Patient record created for Juan Pérez',2),
('treatment','CREATE','Treatment created for patient 1',2),
('appointment','UPDATE','Appointment 1 marked as completed',7);
