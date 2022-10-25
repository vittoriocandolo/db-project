library("ggplot2")
library("RPostgreSQL")
library("dplyr")

driver <- dbDriver("PostgreSQL")
connection <- dbConnect(
  driver,
  dbname = "",
  host = "",
  port = ,
  user = "",
  password = ""
)

numero_progetti_citta <- "select citta, count(*) from cittaprogetto group by citta order by citta;"

res_numero_progetti_citta <- dbGetQuery(connection, numero_progetti_citta) %>%
  rename(Città = citta)

plot_numero_progetti_citta <- ggplot(data = res_numero_progetti_citta) +
  geom_bar(stat = "identity", mapping = aes(x = Città, y = count, fill = Città)) +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Numero di progetti per città",
    x = "Città",
    y = "Numero progetti",
  )

ggsave("./plot_numero_progetti_citta.png", width = 7.5)

dist_dNascita_qualifica <- "select data_di_nascita, qualifica from impiegato;"

res_dist_dNascita_qualifica <- dbGetQuery(connection, dist_dNascita_qualifica) %>%
  rename(Qualifica = qualifica)

plot_dist_dNascita_qualifica <- ggplot(data = res_dist_dNascita_qualifica) +
  geom_boxplot(mapping = aes(x = Qualifica, y = data_di_nascita, fill = Qualifica)) +
  labs(
    title = "Distribuzione data di nascita dei dipendenti per qualifica",
    x = "Qualifica",
    y = "Data di nascita",
    fill = "Qualifica"
  )

ggsave(paste0("./plot_dist_dNascita_qualifica.png"), width = 7.5)

numero_segretari_lingua <- "select lingua, count(*) from segretario group by lingua order by lingua;"

res_numero_segretari_lingua <- dbGetQuery(connection, numero_segretari_lingua) %>%
  rename(Lingua = lingua)

plot_numero_segretari_lingua <- ggplot(data = res_numero_segretari_lingua) +
  geom_bar(stat = "identity", mapping = aes(x = Lingua, y = count, fill = Lingua)) +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Numero di segretari per lingua conosciuta",
    # subtitle = "",
    # caption = "",
    x = "Lingua",
    y = "Numero segretari"
  )

ggsave("./plot_numero_segretari_lingua.png", width = 7.5)

dist_budget_progetto_citta <- "select budget, citta from progetto;"

res_dist_budget_progetto_citta <- dbGetQuery(connection, dist_budget_progetto_citta) %>%
  rename(Città = citta)

options(scipen=10000)

plot_dist_budget_progetto_citta <- ggplot(data = res_dist_budget_progetto_citta) +
  geom_boxplot(mapping = aes(x = Città, y = budget, fill = Città)) +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Distribuzione budget di progetto per città",
    y = "Budget",
    fill = "Città"
  )

ggsave(paste0("./plot_dist_budget_progetto_citta.png"), width = 7.5)

dist_partecipazioni_competenza <- "select descrizione, count(*) from competenza, partecipa where codice = partecipa.competenza group by codice order by descrizione;"

res_dist_partecipazioni_competenza <- dbGetQuery(connection, dist_partecipazioni_competenza) %>%
  rename(Competenza = descrizione)

plot_dist_partecipazioni_competenza <- ggplot(data = res_dist_partecipazioni_competenza) +
  geom_boxplot(mapping = aes(y = count), fill='cornflowerblue') +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Distribuzione delle partecipazioni",
    subtitle = "Numero di partecipazioni per competenza",
    y = "Numero partecipazioni"
  )

ggsave("./plot_dist_partecipazioni_comptenza.png", width = 3.5)

dist_impiegati_dipartimento <- "select dipartimento, count(*) from impiegato, partecipa where matricola = partecipa.impiegato group by dipartimento order by dipartimento"

res_dist_impiegati_dipartimento <- dbGetQuery(connection, dist_impiegati_dipartimento) %>%
  rename(Dipartimento = dipartimento)

plot_dist_impiegati_dipartimento <- ggplot(data = res_dist_impiegati_dipartimento) +
  geom_boxplot(mapping = aes(y = count), fill = 'darkgoldenrod1') +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Distribuzione degli impiegati",
    subtitle = "Numero di impiegati per dipartimento",
    y = "Numero impiegati"
  )

ggsave("./plot_dist_impiegati_dipartimento.png", width = 3.5)

perc_laureati <- "select count(*) from laureato union select count(*) from impiegato where not exists(select * from laureato where matricola = laureato.impiegato);"

res_perc_laureati <- dbGetQuery(connection, perc_laureati)
res_perc_laureati$Gruppo <- c("Laureato", "Non laureato")
res_perc_laureati$count = (res_perc_laureati$count / 3000) * 100

plot_perc_laureati <- ggplot(data = res_perc_laureati, aes(x = "", y = count, fill = Gruppo)) +
  geom_bar(stat="identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Percentuale di impiegati laureati",
    x = "",
    y = ""
  )

ggsave("./plot_perc_laureati.png")

perc_impegati_qualifica <- "select qualifica, count(*)/(sum(count(*)) OVER()) as frequenza from impiegato group by qualifica;"

res_perc_impegati_qualifica <- dbGetQuery(connection, perc_impegati_qualifica) %>%
  rename(Qualifica = qualifica)

plot_perc_impegati_qualifica <- ggplot(data = res_perc_impegati_qualifica, aes(x = "", y = frequenza, fill = Qualifica)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar("y", start = 0) +
  scale_color_brewer(palette="Dark2") +
  theme(axis.text.x=element_blank()) +
  labs(
    title = "Percentuale di impiegati per qualifica",
    x = "",
    y = ""
  )

ggsave("./plot_perc_impegati_qualifica.png", width = 7.5)

