if (!requireNamespace("igraph", quietly=TRUE)) install.packages("igraph", repos="https://cloud.r-project.org")
library(igraph)
g <- make_graph("Zachary")
nodes <- data.frame(id=as.integer(V(g)), name=as.character(V(g)))
em <- as_edgelist(g,names=FALSE); edges <- data.frame(source=em[,1],target=em[,2])
write.csv(nodes,"nodes.csv",row.names=FALSE); write.csv(edges,"edges.csv",row.names=FALSE)
cat("SOCIAL NETWORK ANALYSIS WITH R\nNodes:",vcount(g),"Edges:",ecount(g),"\n")

deg<-degree(g); bet<-betweenness(g,directed=FALSE,normalized=TRUE)
clo<-closeness(g,normalized=TRUE); eig<-eigen_centrality(g)$vector
measures<-data.frame(Node=as.character(V(g)),Degree=as.numeric(deg),Betweenness=as.numeric(bet),Closeness=as.numeric(clo),Eigenvector=as.numeric(eig))
measures<-measures[order(-measures$Degree),]; write.csv(measures,"network_measures.csv",row.names=FALSE)
level<-data.frame(Nodes=vcount(g),Edges=ecount(g),Density=edge_density(g),Diameter=diameter(g),Average_Path_Length=mean_distance(g),Global_Clustering_Coefficient=transitivity(g,type="global"))
write.csv(level,"network_level_measures.csv",row.names=FALSE); print(level)

comm<-cluster_louvain(g); V(g)$community<-membership(comm)
community<-data.frame(Node=as.character(V(g)),Community=as.integer(V(g)$community))
write.csv(community,"community_membership.csv",row.names=FALSE)

influential<-data.frame(Measure=c("Highest Degree","Highest Betweenness","Highest Eigenvector"),
Node=c(measures$Node[which.max(measures$Degree)],measures$Node[which.max(measures$Betweenness)],measures$Node[which.max(measures$Eigenvector)]),
Value=c(max(measures$Degree),max(measures$Betweenness),max(measures$Eigenvector)))
write.csv(influential,"influential_nodes.csv",row.names=FALSE); print(influential)

png("network_basic.png",1200,900); set.seed(123)
plot(g,layout=layout_with_fr(g),vertex.size=8+deg*.7,vertex.label=V(g)$name,vertex.label.cex=.7,vertex.color="skyblue",edge.arrow.size=0,main="Zachary Karate Club Social Network"); dev.off()
png("network_communities.png",1200,900); set.seed(123)
plot(comm,g,layout=layout_with_fr(g),vertex.size=8+deg*.7,vertex.label.cex=.7,main="Community Structure"); dev.off()
top10<-head(measures,10); png("top_degree_nodes.png",1200,700)
barplot(top10$Degree,names.arg=top10$Node,col="steelblue",main="Top 10 Nodes by Degree Centrality",xlab="Node",ylab="Degree"); dev.off()

writeLines(c("BRIEF INTERPRETATION","Nodes represent individuals and edges represent relationships.","High-degree nodes are highly connected.","High-betweenness nodes can act as bridges.","High-eigenvector nodes connect to other important nodes.","Community detection reveals clusters.","","CONCLUSION","The workflow successfully performs network construction, visualization, centrality analysis, community detection and influential-node identification using R."),"interpretation.txt")

validation<-data.frame(Check=c("Graph created","Nodes > 0","Edges > 0","Centrality calculated","Community detection completed"),Result=c(!is.null(g),vcount(g)>0,ecount(g)>0,nrow(measures)==vcount(g),length(unique(V(g)$community))>0))
write.csv(validation,"validation_summary.csv",row.names=FALSE); print(validation)
cat("LAB PS 5 COMPLETED SUCCESSFULLY\n")
