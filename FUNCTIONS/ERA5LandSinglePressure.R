ERA5LandSinglePressure<-function(dataset1,dataset2,knn,nvar){
  # GRIGLIA 1 ----
  grid1<-dataset1
  grid2<-dataset2
  g1day1<-subset(grid1,days==grid1$days[1])
  g1day1$id<-1:nrow(g1day1)
  g1s<-g1day1                               # viene creato un df con tutti i punti della griglia 1
  knn2<-2*knn
  matr_knn<-matrix(data=NA, nrow=nrow(g1s),ncol = knn2) 
  # matrice dei vicini vuota da riempire con le info dei vicini
  col_names_matr_knn<-c()                   #istruzioni per il ciclo -> vettore da riempire con "nn1" "d1" "nn2" "d2" ... "nnk" "dk" per ogni k
  colnk<-seq(1,knn*2,2)                     #istruzioni per il ciclo -> per identificare gli "nn.."
  for (namesk2 in colnk) {                  # --> in questo ciclo vengono create le colonne "nn1" "d1" "nn2" "d2" ... "nnk" "dk" per ogni k
    col_names_matr_knn[c(namesk2,namesk2+1)]<-c(paste0("nn",which(colnk==namesk2)),
                                                paste0("d",which(colnk==namesk2)))} 
  colnames(matr_knn)<-col_names_matr_knn    # assegno i nomi alla matrice
  df_knn<-as.data.frame(matr_knn)           # da matrice a dataframe con i vicini
  g1s<-cbind(g1s,df_knn)                    # le colonne del dataframe con le informazioni sui vicini vengono attaccate ai punti della griglia 1
  coordinates(g1s)<-c("Lon","Lat")          # la griglia 1 al primo giorno è trasformata in un oggetto spaziale
  # GRIGLIA 2 ----
  days_u<-unique(grid2$days)                # viene creato un vettore con i giorni della seconda griglia
  g2day1 <- subset(grid2,days==days_u[1])    # viene creato un df con tutti i punti della griglia 2
  g2day1$id<-c(1:nrow(g2day1))                # viene assegnato un valore univoco ad ogni punto della griglia 2
  for (i in 1:nrow(g1day1)){                   # CICLO PER OGNI PUNTO DELLA PRIMA GRIGLIA
    grid<-g2day1                                # nuovo oggetto uguale a seconda griglia
    coordinates(grid)<-c("Lon","Lat")            # seconda griglia traformata in oggetto spaziale
    grid$dist<-c(spDists(g1s[i,],grid))           # viene creato un vettore con tutte le distanze dal punto "i"
    if(round(min(grid$dist),2)==0){                # se la distanza minima è pari a 0 -------\/
      g1s[i,which(names(g1s)==col_names_matr_knn[1])]<-grid$id[grid$dist==min(grid$dist)][1]    # inserisci solo "nn1" mentre gli altri NA
      g1s[i,which(names(g1s)==col_names_matr_knn[2])]<-grid$dist[grid$dist==min(grid$dist)][1]} # inserisci solo "d1" mentre gli altri NA
    if(round(min(grid$dist),2)!=0){                # se la distanza minima NON è pari a 0
      for (kn in 1:knn){                            # per ogni vicino
        knk<-colnk[kn]                               # sequenza da 1 a k*2 by 2
        g1s[i,which(names(g1s)==col_names_matr_knn[knk])]<-grid$id[grid$dist==min(grid$dist)][1]      # inserisci dentro la griglia del primo giorno
        # le id dei k punti più vicini della seconda griglia
        g1s[i,which(names(g1s)==col_names_matr_knn[knk+1])]<-grid$dist[grid$dist==min(grid$dist)][1]  # inserisci dentro la griglia del primo giorno
        grid<-as.data.frame(grid)                                                                     # la distanza dei k punti più vicini della seconda griglia
        grid<-grid[-(grid$dist==min(grid$dist)),]}}
  }        
  # INTERPOLAZIONE ----
  arr<-array(data=NA,c(length(days_u),nrow(g1s),nvar))# viene creato un vettore che andrà a contenere i valori da interpolare
  for (d in 1:length(days_u)) {    # PER OGNI GIORNO DELLA SECONDA GRIGLIA    
    sub<-subset(grid2,days==days_u[d])
    for (i in 1:nrow(as.data.frame(g1s))){  # PER OGNI PUNTO DELLA PRIMA GRIGLIA 
      g1sdf<-as.data.frame(g1s)                     # la prima griglia da spaziale torna dataframe
      namecolumn<-"d1"                              # istruzione per dopo
      numcolumn<-which(names(g1sdf)==namecolumn)    # identificare la colonna con "d1"
      distk<-g1sdf[i,c(seq(numcolumn,numcolumn+knn,2))] # vettore con le distanze dei vicini dal punto "i"
      distk_inv<-distk^-1                           # vettore con inverso delle distanze
      D<-sum(distk_inv)                             # sommatoria dell' inverso delle distanze
      cov_lo<-list()
      for (k in 1:knn) #PER OGNI VICINO K
      {cov_lo[[k]]<-list()
      namecolumn<-paste0("nn",k)                    # istruzione per dopo
      numcolumn<-which(names(g1sdf)==namecolumn)    # identificare la colonna con "nn1" "nn2" ... "nnk"
      cov_lo[[k]]<-sub[g1sdf[i,numcolumn],c(4:(nvar+3))]}
      for (j in 1:ncol(grid2[,-c(1:3)])) # PER OGNI COLONNA DI VARIABILI DELLA GRIGLIA 2
      { 
        if (names(cov_lo[[1]])[j]=="tp"){arr[d,i,j]<-cov_lo[[1]][,j]}
        if (names(cov_lo[[1]])[j]!="tp")
        {
          if(min(g1s$d1)==0){arr[d,i,j]<-cov_lo[[1]][,j]}  # se la distanza minima è zero
          if(min(g1s$d1)!=0){                                # se la distanza minima non è zero
            val_pesato<-c()   # vettore che conterrà il valore della covariata "j" da attaccare alla riga "i" del data.frame
            for (k in 1:knn) # PER OGNI VICINO K
            {val_pesato<-c(val_pesato,cov_lo[[k]][[d]][,j]*distk_inv[k]/D)} # crea un vettore con i valori pesati (distanza) per la variabile j
            arr[d,i,j]<-sum(val_pesato)
          }                       # arr[d,i,j] -> contiene i valori delle covariate interpolate
        }
      }
    } 
  }
  #weighted mean
  # arr[d,i,j]--> d=days , i=stations , j=covariates
  grid2int<-matrix(c(arr),nrow=nrow(grid1),ncol = nvar)
  colnames(grid2int)<-names(grid2[,-c(1:3)])
  output_interpolation<-cbind(grid1,as.data.frame(grid2int))
  return(output_interpolation)
}