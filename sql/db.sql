CREATE TABLE fornitore (
  partitaiva numeric(11, 0) PRIMARY KEY, 
  nome varchar(50), 
  via varchar(50), 
  civico integer, 
  citta varchar(30)
);

CREATE TABLE dipartimento (
  nome varchar(50) PRIMARY KEY, 
  recapito_telefonico numeric(10, 0) UNIQUE, 
  numero_fornitori integer NOT null DEFAULT 0
);

CREATE TABLE rifornisce (
  dipartimento varchar(50) REFERENCES dipartimento(nome), 
  fornitore numeric(11, 0) REFERENCES fornitore(partitaiva), 
  PRIMARY KEY (dipartimento, fornitore)
);

CREATE TABLE lingua (
  lingua varchar(20) PRIMARY KEY
);

CREATE TABLE impiegato (
  matricola integer PRIMARY KEY, 
  nome varchar (20), 
  cognome varchar (20), 
  data_di_nascita date, 
  data_di_assunzione date, 
  dipartimento varchar(50) REFERENCES dipartimento(nome), 
  qualifica varchar (20), 
  numero_progetti integer NOT null DEFAULT 0
);

CREATE TABLE segretario (
  impiegato integer REFERENCES impiegato(matricola), 
  lingua varchar(20) REFERENCES lingua(lingua)
);

CREATE TABLE competenza (
  codice integer PRIMARY KEY, 
  descrizione varchar (50) UNIQUE
);

CREATE TABLE citta (
  nome varchar (20), 
  regione varchar (20), 
  numero_di_residenti integer, 
  PRIMARY KEY (nome, regione)
);

CREATE TABLE progetto (
  numero integer PRIMARY KEY, 
  budget integer, 
  citta varchar(20), 
  regione varchar(20), 
  FOREIGN KEY(citta, regione) REFERENCES citta(nome, regione)
);

CREATE TABLE matrimonio (
  marito integer REFERENCES impiegato (matricola) PRIMARY KEY, 
  moglie integer REFERENCES impiegato(matricola) UNIQUE NOT null, 
  data_di_matrimonio date, 
  CONSTRAINT marito_moglie_diversi CHECK(marito <> moglie)
);

CREATE TABLE laureato (
  impiegato integer REFERENCES impiegato(matricola), 
  tipo_laurea varchar (20), 
  materia varchar (50), 
  PRIMARY KEY (impiegato, tipo_laurea, materia)
);

CREATE TABLE partecipa (
  impiegato integer REFERENCES impiegato(matricola), 
  competenza integer REFERENCES competenza(codice), 
  progetto integer REFERENCES progetto(numero), 
  PRIMARY KEY(impiegato, competenza, progetto)
);

CREATE VIEW cittaprogetto(progetto, citta, regione) AS 
SELECT 
  p.numero, 
  ct.nome, 
  ct.regione 
FROM 
  progetto p 
  JOIN citta ct ON p.citta = ct.nome 
  AND p.regione = ct.regione;

CREATE 
OR REPLACE FUNCTION max_progetto_citta() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN IF (
  new.competenza <> old.competenza 
  AND (
    new.progetto = old.progetto 
    AND new.impiegato = old.impiegato
  )
) THEN RETURN new;
END IF;
IF (
  NOT EXISTS (
    SELECT 
      * 
    FROM 
      progetto, 
      partecipa, 
      cittaprogetto 
    WHERE 
      new.progetto = progetto.numero 
      and new.impiegato = partecipa.impiegato 
      and partecipa.progetto = cittaprogetto.progetto 
      and progetto.citta = cittaprogetto.citta
  )
) THEN RETURN new;
END IF;
Return old;
END $$;

CREATE TRIGGER max_progetto_citta before INSERT 
OR 
UPDATE 
  ON partecipa FOR each ROW execute procedure max_progetto_citta();

CREATE 
OR REPLACE FUNCTION impiegato_segretario() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN IF (
  new.qualifica = 'Segretario' 
  AND (
    NOT EXISTS (
      SELECT 
        impiegato 
      FROM 
        segretario 
      WHERE 
        impiegato = new.matricola
    )
  )
) THEN RETURN old;
END IF;
RETURN new;
END $$;

CREATE TRIGGER impiegato_segretario before 
UPDATE 
  ON impiegato FOR each ROW execute procedure impiegato_segretario();

CREATE 
OR replace FUNCTION numero_fornitori_inc() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  dipartimento 
SET 
  numero_fornitori = numero_fornitori + 1 
WHERE 
  nome = new.dipartimento;
RETURN new;
END;
$$;

CREATE TRIGGER numero_fornitori_inc before 
INSERT 
    ON rifornisce FOR each ROW execute procedure numero_fornitori_inc();

CREATE 
OR replace FUNCTION numero_fornitori_dec() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  dipartimento 
SET 
  numero_fornitori = numero_fornitori - 1 
WHERE 
  nome = old.dipartimento;
RETURN old;
END;
$$;

CREATE TRIGGER numero_fornitori_dec before 
DELETE 
    ON rifornisce FOR each ROW execute procedure numero_fornitori_dec();

CREATE 
OR replace FUNCTION numero_fornitori_update() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  dipartimento 
SET 
  numero_fornitori = numero_fornitori + 1 
WHERE 
  nome = new.dipartimento;
UPDATE 
  dipartimento 
SET 
  numero_fornitori = numero_fornitori - 1 
WHERE 
  nome = old.dipartimento;
RETURN new;
END;
$$;

CREATE TRIGGER numero_fornitori_update before 
UPDATE 
  ON rifornisce FOR each ROW execute procedure numero_fornitori_update();

CREATE 
OR replace FUNCTION numero_progetti_inc() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  impiegato 
SET 
  numero_progetti = numero_progetti + 1 
WHERE 
  matricola = new.impiegato;
RETURN new;
END;
$$;

CREATE TRIGGER numero_progetti_inc before 
INSERT 
    ON partecipa FOR each ROW execute procedure numero_progetti_inc();

CREATE 
OR replace FUNCTION numero_progetti_dec() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  impiegato 
SET 
  numero_progetti = numero_progetti - 1 
WHERE 
  matricola = old.impiegato;
RETURN old;
END;
$$;

CREATE TRIGGER numero_progetti_dec before 
DELETE 
    ON partecipa FOR each ROW execute procedure numero_progetti_dec();

CREATE 
OR replace FUNCTION numero_progetti_update() RETURNS TRIGGER LANGUAGE plpgsql AS $$ BEGIN 
UPDATE 
  impiegato 
SET 
  numero_progetti = numero_progetti + 1 
WHERE 
  matricola = new.impiegato;
UPDATE 
  impiegato 
SET 
  numero_progetti = numero_progetti - 1 
WHERE 
  matricola = old.impiegato;
RETURN new;
END;
$$;
CREATE TRIGGER numero_progetti_update before 
UPDATE 
  ON partecipa FOR each ROW execute procedure numero_progetti_update();

CREATE INDEX index_impiegato_qualifica ON impiegato(qualifica);

CREATE INDEX index_impiegato_dataAssunzione ON impiegato(data_di_assunzione);

CREATE INDEX index_progetto_budget ON progetto(budget);

