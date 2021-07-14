#***************************
#******** ECS Cluster ******
#***************************

#---------- ECS Cluster  ----------
resource "aws_ecs_cluster" "Cluster" {
  name = "Cluster-${var.Environment}"
  tags = {
    Created_by = "Terraform"
  }
}