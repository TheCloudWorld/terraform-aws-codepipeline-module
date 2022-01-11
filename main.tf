resource "aws_codepipeline" "codepipeline" {
  name     = var.codepipeline_name
  role_arn = data.aws_iam_role.iam_role_codepipeline.arn

  artifact_store {
    location = data.aws_s3_bucket.s3_bucket_artifact_store.id
    type     = "S3"
  }
  ################################################################
  ## Source Stage
  ################################################################
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = "arn:aws:codestar-connections:us-east-1:667481606687:connection/1430ac9f-f7d3-47d0-8114-7035fa2294a4"
        FullRepositoryId = "wilshan/spring-boot-rds"
        BranchName       = "main"
      }
    }
  }
  ################################################################
  ## Build Stage
  ################################################################
  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"
      configuration = {
        ProjectName = var.codebuild_project_name
      }
    }
  }
  ################################################################
  ## Deploy Stage
  ################################################################
  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      version         = "1"
      run_order       = "1"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      region          = var.target_region
      configuration = {
        ApplicationName     = var.codedeploy_app_and_group_name
        DeploymentGroupName = var.codedeploy_app_and_group_name
      }
    }
  }


}
