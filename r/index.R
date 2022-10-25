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

interrogazione <- ""
creaIndice <- ""
dropIndice <- ""

dbGetQuery(connection, interrogazione)

senzaI <- data.frame(stringsAsFactors = FALSE)
for (var in 0:49) {
  senzaI <- rbind(senzaI, dbGetQuery(connection, interrogazione)[5:6,], stringsAsFactors = FALSE)
}

dbGetQuery(connection, creaIndice)

dbGetQuery(connection, interrogazione)

conI <- data.frame(stringsAsFactors = FALSE)
for (var in 0:49) {
  conI <- rbind(conI, dbGetQuery(connection, interrogazione)[5:6,], stringsAsFactors = FALSE)
}

dbGetQuery(connection, dropIndice)

colnames(senzaI)[1] <- "Planning senza indice"
colnames(senzaI)[2] <- "Execution senza indice"
colnames(conI)[1] <- "Planning con indice"
colnames(conI)[2] <- "Execution con indice"

senzaI <- mutate(senzaI, id = rownames(senzaI))
conI <- mutate(conI, id = rownames(conI))

res <- inner_join(senzaI, conI) %>%
  select(-id)
  
write.csv(res, paste0("./", paste0(interrogazione, ".csv")), quote = FALSE, row.names = FALSE)

senzaI$"Tipo" <- "senza"
conI$"Tipo" <- "con"

colnames(senzaI)[1] <- "Planning"
colnames(senzaI)[2] <- "Execution"
colnames(conI)[1] <- "Planning"
colnames(conI)[2] <- "Execution"

res <- rbind(senzaI, conI)

plot <- ggplot(res, aes(fill = Tipo)) +
  geom_boxplot(aes(Tipo, Planning), outlier.shape = NA) +
  coord_cartesian(ylim = quantile(res$Planning, c(0.1, 0.9)))
  
ggsave(paste0("./", paste0("planning_", interrogazione, ".png")), width = 7.5)

plot <- ggplot(res, aes(fill = Tipo)) +
  geom_boxplot(aes(Tipo, Execution), outlier.shape = NA) +
  coord_cartesian(ylim = quantile(res$Execution, c(0.1, 0.9)))
  
ggsave(paste0("./", paste0("execution_", interrogazione, ".png")), width = 7.5)

