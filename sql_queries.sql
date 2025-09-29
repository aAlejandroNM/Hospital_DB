
SELECT a.id AS appointment_id, per_pat.name AS patient_name, per_doc.name AS doctor_name, a.date
FROM appointment a
INNER JOIN patient pat ON a.patient_id = pat.id
INNER JOIN person per_pat ON pat.id = per_pat.id
INNER JOIN doctor doc ON a.doctor_id = doc.staff_id
INNER JOIN staff sdoc ON doc.staff_id = sdoc.id
INNER JOIN person per_doc ON sdoc.id = per_doc.id;

SELECT t.id AS treatment_id, per.name AS patient_name, d.name AS disease_name, t.name AS treatment_name
FROM treatment t
INNER JOIN patient p ON t.patient_id = p.id
INNER JOIN person per ON p.id = per.id
INNER JOIN disease d ON t.disease_id = d.id;

SELECT tm.treatment_id, t.name AS treatment_name, m.name AS medicine_name, tm.dosage
FROM treatment_medicine tm
INNER JOIN treatment t ON tm.treatment_id = t.id
INNER JOIN medicine m ON tm.medicine_id = m.id;

SELECT per.id AS person_id, per.name AS person_name, COUNT(a.id) AS appointments_count
FROM person per
LEFT JOIN patient p ON per.id = p.id
LEFT JOIN appointment a ON p.id = a.patient_id
GROUP BY per.id, per.name;

SELECT d.staff_id AS doctor_staff_id, per.name AS doctor_name
FROM person per
RIGHT JOIN staff s ON per.id = s.id
RIGHT JOIN doctor d ON s.id = d.staff_id;

SELECT s.code AS status_code, a.id AS appointment_id
FROM appointment a
RIGHT JOIN appointment_status s ON a.status_id = s.id;

SELECT m.id AS medicine_id, m.name AS medicine_name, im.id AS movement_id, im.change_qty
FROM inventory_movement im
RIGHT JOIN medicine m ON im.medicine_id = m.id;

SELECT md.id AS document_id, md.document_type, mr.patient_id
FROM medical_record mr
RIGHT JOIN medical_document md ON mr.id = md.id;

SELECT s.id AS symptom_id, s.name AS symptom_name, ds.disease_id
FROM disease_symptom ds
RIGHT JOIN symptom s ON ds.symptom_id = s.id;

SELECT p.id AS patient_id, per.name AS patient_name, ps.noted_at
FROM patient_symptom ps
RIGHT JOIN patient p ON ps.patient_id = p.id
LEFT JOIN person per ON p.id = per.id;

SELECT ms.id AS specialty_id, ms.name AS specialty_name, s.id AS staff_id
FROM staff s
RIGHT JOIN medical_specialty ms ON s.specialty_id = ms.id;

SELECT m.id AS medicine_id, m.name AS medicine_name, tm.treatment_id
FROM treatment_medicine tm
RIGHT JOIN medicine m ON tm.medicine_id = m.id;


SELECT s.id AS staff_id, per.name AS staff_name, a.action
FROM audit_log a
RIGHT JOIN staff s ON a.actor_staff_id = s.id
LEFT JOIN person per ON s.id = per.id;

SELECT d.id AS disease_id, d.name AS disease_name, COUNT(mr.id) AS records_count
FROM disease d
LEFT JOIN medical_record mr ON d.id = mr.disease_id
GROUP BY d.id, d.name;

SELECT ms.id AS specialty_id, ms.name AS specialty_name, AVG(per.age) AS avg_age
FROM medical_specialty ms
JOIN staff s ON ms.id = s.specialty_id
JOIN person per ON s.id = per.id
GROUP BY ms.id, ms.name;

SELECT m.id AS medicine_id, m.name AS medicine_name, SUM(im.change_qty) AS total_movement
FROM medicine m
LEFT JOIN inventory_movement im ON m.id = im.medicine_id
GROUP BY m.id, m.name;

SELECT ms.id AS specialty_id, ms.name AS specialty_name, AVG(per.age) AS avg_age
FROM medical_specialty ms
JOIN staff s ON ms.id = s.specialty_id
JOIN person per ON s.id = per.id
GROUP BY ms.id, ms.name
HAVING AVG(per.age) > 40;

SELECT d.id AS disease_id, d.name AS disease_name, COUNT(mr.id) AS records_count
FROM disease d
LEFT JOIN medical_record mr ON d.id = mr.disease_id
GROUP BY d.id, d.name
HAVING COUNT(mr.id) >= 1;

SELECT m.id AS medicine_id, m.name AS medicine_name, COALESCE(SUM(im.change_qty),0) AS net_movement
FROM medicine m
LEFT JOIN inventory_movement im ON m.id = im.medicine_id
GROUP BY m.id, m.name
HAVING COALESCE(SUM(im.change_qty),0) < 0;

SELECT
  t.id AS treatment_id,
  t.name AS treatment_name,
  p.id AS patient_id,
  per_pat.name AS patient_name,
  d.id AS disease_id,
  d.name AS disease_name,
  GROUP_CONCAT(DISTINCT m.name SEPARATOR ', ') AS medicines_used,
  GROUP_CONCAT(DISTINCT CONCAT(DOC_PER.name, ' (staff:', sdoc.id,')') SEPARATOR ' | ') AS doctors_involved,
  GROUP_CONCAT(DISTINCT CONCAT('appt:', a.id, ' @', a.date) SEPARATOR ' || ') AS related_appointments
FROM treatment t
LEFT JOIN patient p ON t.patient_id = p.id
LEFT JOIN person per_pat ON p.id = per_pat.id
LEFT JOIN disease d ON t.disease_id = d.id
LEFT JOIN treatment_medicine tm ON t.id = tm.treatment_id
LEFT JOIN medicine m ON tm.medicine_id = m.id
LEFT JOIN appointment a ON a.patient_id = p.id
LEFT JOIN doctor doc ON a.doctor_id = doc.staff_id
LEFT JOIN staff sdoc ON doc.staff_id = sdoc.id
LEFT JOIN person DOC_PER ON sdoc.id = DOC_PER.id
GROUP BY t.id, t.name, p.id, per_pat.name, d.id, d.name
ORDER BY t.id;