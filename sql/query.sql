-- ricerca dei fornitori di un dipartimento
SELECT 
  fornitore 
FROM 
  rifornisce 
WHERE 
  rifornisce.dipartimento = 'B028';
  
-- ricerca dei segretari che conoscono una determinata lingua
SELECT 
  impiegato.matricola, 
  impiegato.nome, 
  impiegato.cognome;
FROM 
  impiegato, 
  segretario 
WHERE 
  impiegato.matricola = segretario.impiegato 
  AND lingua = 'Russo';
  
-- ricerca degli impiegati con determinata competenza
SELECT 
  DISTINCT matricola 
FROM 
  impiegato 
  JOIN partecipa ON impiegato.matricola = partecipa.impiegato 
WHERE 
  partecipa.competenza = 824;
  
-- ricerca delle competenze di un impiegato
SELECT 
  competenza 
FROM 
  partecipa 
WHERE 
  impiegato = 69992;
  
-- ricerca degli impiegati coniugati
SELECT 
  DISTINCT matricola 
FROM 
  impiegato 
WHERE 
  matricola IN (
    SELECT 
      marito 
    FROM 
      matrimonio
  ) 
  or matricola IN (
    SELECT 
      moglie 
    FROM 
      matrimonio
  );
  
-- ricerca dei laureati in una materia
SELECT 
  impiegato 
FROM 
  laureato 
WHERE 
  materia = 'Physics';
  
-- ricerca delle citta in cui l'azienda opera
SELECT 
  DISTINCT citta 
FROM 
  progetto;
  
-- ricerca del numero di dipendenti per citta
SELECT 
  count(DISTINCT impiegato) 
FROM 
  partecipa AS p 
  JOIN progetto AS ptt ON p.progetto = ptt.numero 
WHERE 
  citta = 'El Paso';
  
-- ricerca del numero di progetti a cui lavora un impiegato
SELECT 
  numero_progetti 
FROM 
  impiegato 
WHERE 
  matricola = 69992;
  
-- ricerca del numero di fornitori di un dipartimento
SELECT 
  numero_fornitori 
FROM 
  dipartimento 
WHERE 
  nome = 'B028';
  
-- assegnazione di un progetto ad un impiegato
INSERT INTO partecipa(impiegato, competenza, progetto) 
VALUES 
  (69992, 3247, 13);
  
-- assegnazione di un fornitore a un dipartimento
INSERT INTO rifornisce(dipartimento, fornitore) 
VALUES 
  ('V8644XS', 23489419167);
  
-- inserimento di un impiegato con la qualifica di segretario
INSERT INTO impiegato (matricola, nome, cognome, data_di_nascita, data_di_assunzione, dipartimento, qualifica) 
VALUES 
	(28172, 'Lianna', 'Vitler', '1980/04/25', '2019/05/05', 'C221', null);

INSERT INTO segretario (impiegato, lingua) 
VALUES 
	(28172, 'Russo');

UPDATE 
  impiegato 
SET 
  qualifica = 'Segretario' 
WHERE 
  matricola = 28172;

