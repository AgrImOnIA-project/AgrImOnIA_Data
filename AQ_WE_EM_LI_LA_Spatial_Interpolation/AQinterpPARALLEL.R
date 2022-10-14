"%notin%"<-Negate("%in%")
AQinterpPARALLEL <- function(AQ,dataset2,knn,nvar){
  AQ_meta<-unique(AQ[,1:3])
  dataset2_meta<-unique(dataset2[,1:2])
  dataset2_meta$ID<-1:nrow(dataset2_meta)
  dataset2<-merge(dataset2,dataset2_meta,all.x=T)
  AQ_knn<-foreach(i = 1:nrow(AQ_meta), .packages = "sp", .combine = rbind) %dopar%
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
    }
  names(AQ_knn)[-c(1:3)]<-c(paste0("nn",1:knn),paste0("dist",1:knn))
  nn_all<-unique(c(as.matrix(AQ_knn[,c(4:(3+knn))])))
  dataset2<-dataset2[dataset2$ID %in% nn_all,]
  varcl<-c()
  for (i in 1:(nvar)) {
    varcl[i]<-(class(dataset2[,3+i]))
  }
  varnum<-which(varcl=="numeric")
  varfac<-which(varcl=="factor")
  AQ_dataset2<-foreach(d = unique(AQ$time), .combine = rbind, .packages = "doParallel") %dopar% 
    {
      sub_AQ<-subset(AQ,time==d)
      sub_dataset2<-subset(dataset2,days==d)
      AQ_meta2<-foreach (s = unique(sub_AQ$IDStation), .combine = rbind) %dopar% {
        AQ_knn_s<-subset(AQ_knn,IDStation==s)
        nn<-c(t(AQ_knn_s[,4:(3+knn)]))
        dist<-c(t(AQ_knn_s[,8:(7+knn)]))
        var<-matrix(nrow = knn,ncol = nvar)
        if (0 %in% dist){
          for (k in 1:knn) {
            sub_s_dataset2<-subset(sub_dataset2,ID==nn[1])
            var[k,varnum]<-as.vector(as.matrix(sub_s_dataset2[,3+varnum]))
            var[k,varfac]<-c(as.numeric(sub_s_dataset2[,3+varfac]))
          }}
        "%notin%"<-Negate("%in%")
        if (0 %notin% dist){
        inv_dist<-dist^-1
        inv_D<-sum(inv_dist)
        dist_stand<-inv_dist/inv_D
        for (k in 1:knn) {
          sub_s_dataset2<-subset(sub_dataset2,ID==nn[k])
          var[k,varnum]<-as.vector(as.matrix(sub_s_dataset2[,3+varnum]*dist_stand[k]))
          var[k,varfac]<-c(as.numeric(sub_s_dataset2[,3+varfac]))
        }}
        var_pesato<-matrix(nrow = 1,ncol = nvar)
        for (vnum in varnum) {
          var_pesato[,vnum]<-sum(var[,vnum])
        }
        for (vfac in varfac) {
          uniqv <- unique(var[,vfac])
          var_pesato[,vfac]<-uniqv[which.max(tabulate(match(var[,vfac], uniqv)))]
        }
        colnames(var_pesato)<-names(dataset2[,4:(3+nvar)])
        var_pesato<-as.data.frame(var_pesato)
        for (vfac in varfac) {
          var_pesato[,vfac]<-as.character(levels(sub_s_dataset2[,3+vfac])[var_pesato[,vfac]])
          levels(var_pesato[,vfac])<-levels(sub_s_dataset2[,3+vfac])
        }
        AQ_meta2 <- cbind(AQ_knn_s[,1:3],sub_AQ[1,4],var_pesato)
        names(AQ_meta2)[4]<-"time"
        AQ_meta2
      }
    }
  return(AQ_dataset2)
}
