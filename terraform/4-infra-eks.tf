# Create EKS IAM role
resource "aws_iam_role" "infra_eks_cluster_role" {
  name = "infra-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "infra_eks_cluster_policy" {
  role       = aws_iam_role.infra_eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


/*# EKS Cluster
resource "aws_eks_cluster" "infra_eks" {
  name     = "infra-eks"
  role_arn = aws_iam_role.infra_eks_cluster_role.arn

  vpc_config {
    subnet_ids = [for subnet in aws_subnet.infra_eks : subnet.id]
  }

  version = "1.29"

  depends_on = [aws_iam_role_policy_attachment.infra_eks_cluster_policy]
}

*/
