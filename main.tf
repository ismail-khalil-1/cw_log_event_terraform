


resource "null_resource" "fetch_log_events" {
  provisioner "local-exec" {
    command = <<EOT
    
	./test.sh


    EOT
  }
}
