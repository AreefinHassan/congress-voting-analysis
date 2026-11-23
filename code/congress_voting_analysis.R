# Clustering analysis in R
# Part 1: k-means and hierarchical clustering of US utility companies
# (data/Utilities.csv). The 1984 Congress votes k-means analysis (k = 2)
# is documented in report/Congress_Voting_Report.pdf.
#
library(stats)

#load data
utilities.df<-read.csv("data/Utilities.csv")
row.names(utilities.df)=utilities.df[,1]
utilities.df<-utilities.df[,-1]

#normalized data
utilities.df.norm<- sapply(utilities.df,scale)
row.names(utilities.df.norm)<-row.names(utilities.df)

#computing normalized distance based on 8 variables
d.norm<-dist(utilities.df.norm,method = "euclidean")


#in hclust() setting argument method
hc1<-hclust(d.norm,method = "single")
plot(hc1,hang=-1,ann=FALSE)

memb<-cutree(hc1,k=4)
memb



#setting labels as cluster membership 
row.names(utilities.df.norm)<-paste(memb,":",row.names(utilities.df),sep="")
#plotting heatmap
##############
heatmap(as.matrix(utilities.df.norm),Colv = NA,hclustfun = hclust,
        col=rev(paste("green",1:99,sep="")))

#########################
# Create a color palette function
pinkPalette <- colorRampPalette(c("lightgreen", "purple"))

# Generate 99 shades of pink
pinkColors <- pinkPalette(99)

# Use the generated colors in your heatmap
heatmap(as.matrix(utilities.df.norm), Colv = NA, hclustfun = hclust, col = pinkColors)

#running k means clustering

set.seed(234)
km<-kmeans(utilities.df.norm,6)



#showing cluster membership
km$cluster

#centroids
km$centers


#plotting empty scatter plot
plot(c(0),xaxt='n',ylab="",type="l",
     ylim=c(min(km$centers),max(km$centers)),xlim=c(0,8))

#label x
axis(1,at=c(1:8),labels=names(utilities.df))
#plot centroids
for (i in c(1:6))
  lines(km$centers[i,], lty=i,lwd=2, col=ifelse(i %in% c(1,3,5),
                                                "black","orange"))
                                                
#naming clusters
text(x=0.5 ,y=km$centers[,1],labels=paste("Cluster",c(1:6)))

#########################################################################################


# Required packages: ggplot2, cluster, reshape2
library(ggplot2)
library(cluster)
library(reshape2)



# Assuming 'utilities.df.norm' is your normalized data frame

# Function to perform k-means and plot centroids
perform_kmeans <- function(data, k) {
  set.seed(42) # for reproducibility
  km <- kmeans(data, centers = k)
  
  # Obtain cluster means for plotting
  centroids <- as.data.frame(km$centers)
  centroids$cluster <- factor(1:k)
  
  # Melt the data for ggplot2
  centroids_long <- reshape2::melt(centroids, id.vars = "cluster")
  
  # Plotting with ggplot2
  p <- ggplot(centroids_long, aes(x = variable, y = value, group = cluster, color = cluster)) +
    geom_line() +
    geom_point() +
    theme_minimal() +
    labs(title = paste("K-means Cluster Centroids for k =", k),
         x = "Feature",
         y = "Centroid Value")
  
  print(p)
  
  # Calculate silhouette score
  silhouette_score <- silhouette(km$cluster, dist(data))
  avg_sil_width <- mean(silhouette_score[, 'sil_width'])
  
  cat("For k =", k, "the average silhouette width is", avg_sil_width, "\n\n")
  
  return(list(model = km, plot = p, silhouette = avg_sil_width))
}

# Apply k-means with k=4 and k=13
results_k4 <- perform_kmeans(utilities.df.norm, 4)
results_k13 <- perform_kmeans(utilities.df.norm, 13)

# You can access the plot and silhouette score like this:
results_k4$plot
results_k4$silhouette
results_k13$plot
results_k13$silhouette


# Assuming 'utilities.df.norm' is your normalized data frame

# Function to perform hierarchical clustering and plot the dendrogram
perform_hclust <- function(data, method) {
  # Compute the dissimilarity matrix
  d <- dist(data)
  
  # Hierarchical clustering using specified method
  hc <- hclust(d, method = method)
  
  # Plot the dendrogram
  plot(hc, main = paste("Dendrogram using", method, "linkage"), sub = "")
  
  return(hc)
}

# Apply hierarchical clustering with "average" linkage
hc_average <- perform_hclust(utilities.df.norm, "average")

# Apply hierarchical clustering with "complete" linkage
hc_complete <- perform_hclust(utilities.df.norm, "complete")

# To cut the tree at k=4 and k=13, you can use the cutree() function:
# For "average" linkage
clusters_avg_k4 <- cutree(hc_average, k = 4)
clusters_avg_k13 <- cutree(hc_average, k = 13)

# For "complete" linkage
clusters_comp_k4 <- cutree(hc_complete, k = 4)
clusters_comp_k13 <- cutree(hc_complete, k = 13)

# Function to plot heatmap for given k-means clustering results
plot_heatmap <- function(km, data) {
  # Order the data by the clustering results
  data_ordered <- data[order(km$cluster), ]
  
  # Create a color palette for the heatmap
  my_palette <- colorRampPalette(c("blue", "white", "red"))(n = 299)
  
  # Generate the heatmap
  heatmap(as.matrix(data_ordered), 
          Colv = NA, # Do not reorder columns
          Rowv = as.dendrogram(hclust(dist(data_ordered))), # Reorder rows by hierarchical clustering
          col = my_palette, 
          scale = "none", # Data is already normalized
          margins = c(5, 10), # Adjust margins for better fit of row names
          xlab = "Features", 
          ylab = "Clusters"
  )
}

# Assuming you have already executed k-means clustering with k=4 and k=13 and have the results in km_4 and km_13
# Ensure the 'utilities.df.norm' data frame is available in your environment.
# Perform k-means clustering with k=4
set.seed(42) # Setting a seed for reproducibility
km_4 <- kmeans(utilities.df.norm, centers = 4)

# Perform k-means clustering with k=13
set.seed(42) # Setting a seed for reproducibility
km_13 <- kmeans(utilities.df.norm, centers = 13)

# Assuming the plot_heatmap function is defined as provided previously
# Plot heatmap for k=4
plot_heatmap(km_4, utilities.df.norm)

# Plot heatmap for k=13
plot_heatmap(km_13, utilities.df.norm)










