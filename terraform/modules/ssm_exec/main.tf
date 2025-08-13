resource "null_resource" "ssm_exec" {
  provisioner "local-exec" {
    command = <<EOT
      set -e

      CMD_ID=$(aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --region "${var.region}" \
        --instance-ids "${var.instance_id}" \
        --comment "Running remote command via SSM" \
        --parameters 'commands=[${join(",", var.commands)}]' \
        --region ${var.region} \
        --query "Command.CommandId" \
        --output text)

      echo "Waiting for command $${CMD_ID} to finish..."

      aws ssm wait command-executed \
        --instance-id ${var.instance_id} \
        --command-id $CMD_ID \
        --region ${var.region}

      STATUS=$(aws ssm list-command-invocations \
        --command-id $CMD_ID \
        --details \
        --region ${var.region} \
        --query "CommandInvocations[0].Status" \
        --output text)

      if [ "$STATUS" != "Success" ]; then
        echo "SSM command failed with status: $STATUS"
        exit 1
      fi

      echo "✅ command executed successfully"
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

/*

resource "null_resource" "ssm_exec" {
  triggers = {
    instance_id = var.instance_id
    commands    = join(",", var.commands)
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ssm send-command \
        --document-name "AWS-RunShellScript" \
        --region "${var.region}" \
        --instance-ids "${var.instance_id}" \
        --comment "Running remote command via SSM" \
        --parameters 'commands=[${join(",", var.commands)}]' \
        --output text
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}
*/
