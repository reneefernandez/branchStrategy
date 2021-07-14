output "ARN_Cluster" {
   value = aws_ecs_cluster.Cluster.id
}

output "Cluster_Name" {
   value = aws_ecs_cluster.Cluster.name
}
