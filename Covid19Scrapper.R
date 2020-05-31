#####  Extractor de datos COVID 19 MX  #####
#
#
# Descripcion: Script para extraer de manera 
#              automatizada los datos más relevantes 
#              sobre la evolución de la pandemia en Mexico. 
#              A nivel nacional. 
#              - Casos confirmados 
#              - Negativos
#              - Sospechosos
#              - Defunciones
#              - Recuperados (Estimados)
#              - Activos
# 
# Fecha: 18 de Mayo 2020 
# Autor: Gibrán Garibay Fregoso
# Contacto: gibran.garibay.fregoso@gmail.com 
#
# Sistema 
# R version 3.6.2 (2019-12-12)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# Running under: Windows 10 x64 (build 18362)
#
# Librerias

library(dplyr)
library(rvest)
library(RSelenium)
library(stringr)

# Inicializar el driver 
# driver = la conexion entre tu codigo y el navegador
driver <- rsDriver(chromever = "83.0.4103.39",port =  as.integer(5556)) 
remDr <- driver[["client"]]


remDr$maxWindowSize()

# Ir al sitio 
remDr$navigate("https://coronavirus.gob.mx/datos/")

### Numero de casos confirmados
variables <- c("Confirmados","Negativos","Sospechosos","Defunciones")

# lista para guardar los datos
data <- list()


for(var in variables){
 selector <- paste0("div[onclick=\"$('#sPatType').selectpicker('val', ", "'",var,"'); reUpdate();\"]")
 # encontrar el recuadro principal de cada variable 
 object <- remDr$findElement("css selector",selector)
 # dentro de ese cuadro encontra el numero que le corresponde
 number <- object$findChildElement("css selector","div[id^=gs]")
 # Extraer ese numero y llevarlo a numerico
 n <- number$getElementText() %>% str_replace(",","") %>% as.numeric()
 # Print para saber que esta pasando
 print(var)
 print(n)
 
 # Clic para obtener mayor detalle de la variable
 object$clickElement()
 # ... Esperemos que cargue 
 Sys.sleep(7)
 
 # Porcentaje de mujeres
 mujeres <- remDr$findElement("css selector","#vFem") 
 nmujeres <- mujeres$getElementText()[[1]] %>%
   str_extract("[\\d\\.]+") %>% as.numeric()
 
 # Porcentaje de hombres
 hombres <- remDr$findElement("css selector","#vMas") 
 nhombres <- hombres$getElementText()[[1]] %>% 
   str_extract("[\\d\\.]+") %>% as.numeric()
 
 # Hospitalizados 
 hosp <- remDr$findElement("css selector","#vHos") 
 phosp <- hosp$getElementText()[[1]] %>%
   str_extract("[\\d\\.]+") %>% as.numeric()
 
 # Ambulatorios
 amb <- remDr$findElement("css selector","#vAmb") 
 pamb <- amb$getElementText()[[1]] %>% 
   str_extract("[\\d\\.]+") %>% as.numeric()
 
 # Comorbilidades!
 
 hipertension <-  remDr$findElement("css selector","div#vCM1")
 phip <- hipertension$getElementText() %>%
   str_extract("[\\d\\.]+") %>% as.numeric()
 
 # Data frame con todos datos de la variable 
 data[[var]] <- (data.frame(variable =var,
            Numero = n,
            porcentaje_mujeres = nmujeres,
            porcentaje_hombres = nhombres,
            porcentaje_amb = pamb,
            porcentaje_hosp = phosp,
            porcentaje_hipertension = phip,
            fecha = Sys.time()))
 
}

# Consolidemos los resultados en un solo data frame! y listo :) 
data %>% bind_rows() %>% View()



