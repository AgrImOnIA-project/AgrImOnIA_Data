AQinterp <- function(AQ,dataset2,knn,nvar){
  AQ_meta<-unique(AQ[,1:3])
  dataset2_meta<-unique(dataset2[,1:2])
  dataset2_meta$ID<-1:nrow(dataset2_meta)
  dataset2<-merge(dataset2,dataset2_meta,all.x=T)
  AQ_knn<-data.frame()
for(i in 1:nrow(AQ_meta))
    {
      point<-AQ_meta[i,]
      coordinates(point)<-c(names(point)[c(2,3)])
      grid<-dataset2_meta
      coordinates(grid)<-c(names(grid)[c(1,2)])
      grid$dist<-c(spDists(point,grid))
      dist_o<-spDists(point,grid)
      dist_m<-dist_o[order(dist_o,decreasing=F)]
      dist_m<-dist_m[c(1:knn)]
      nn<-c()
      for (k in 1:knn){nn[k]<-grid$ID[which(grid$dist==dist_m[k])]}
      df<-as.data.frame(matrix(c(nn,dist_m),byrow = T,nrow = 1,ncol = knn*2))
      df<-cbind(AQ_meta[i,],df)
      AQ_knn[i,]<-df
    }
  names(AQ_knn)[-c(1:3)]<-c(paste0("nn",1:knn),paste0("dist",1:knn))
  nn_all<-unique(c(as.matrix(AQ_knn[,c(4:(3+knn))])))
  dataset2<-dataset2[dataset2$ID %in% nn_all,]
  varcl<-c()
  for (i in 1:nvar) {
    varcl[i]<-(class(dataset2[,3+i]))
  }
  varnum<-which(varcl=="numeric")
  varfac<-which(varcl=="factor")
  source("FUNCTIONS/getmode.R")
  AQ_dataset2<-data.frame()
  for (d in unique(AQ$time)) 
    {
      sub_AQ<-subset(AQ,time==d)
      sub_dataset2<-subset(dataset2,days==d)
      AQ_meta2<-foreach (s = unique(sub_AQ$IDStation), .combine = rbind) %dopar% {
        AQ_knn_s<-subset(AQ_knn,IDStation==s)
        nn<-c(t(AQ_knn_s[,4:7]))
        inv_dist<-c(t(AQ_knn_s[,8:11]))^-1
        inv_D<-sum(inv_dist)
        dist_stand<-inv_dist/inv_D
        var<-matrix(nrow = knn,ncol = nvar)
        for (k in 1:knn) {
          sub_s_dataset2<-subset(sub_dataset2,ID==nn[k])
          var[k,varnum]<-c(t(sub_s_dataset2[,3+varnum]*dist_stand[k]))
          var[k,varfac]<-sub_s_dataset2[,3+varfac]
        }
        var_pesato<-matrix(nrow = 1,ncol = nvar)
        for (vnum in varnum) {
          var_pesato[,vnum]<-sum(var[,vnum])
        }
        for (vfac in varfac) {
          var_pesato[,vfac]<-getmode(var[,vfac])
        }
        colnames(var_pesato)<-names(dataset2[,4:(3+nvar)])
        AQ_meta2 <- cbind(AQ_knn_s[,1:3],sub_AQ[1,4],as.data.frame(var_pesato))
        names(AQ_meta2)[4]<-"time"
        AQ_dataset2[d,]<-AQ_meta2
      }
      for (nfac in vfac) {
        AQ_dataset2[,nfac]<-levels(dataset2[,nfac])[AQ_dataset2[,nfac]]
      }
    }
  return(AQ_dataset2)
}
