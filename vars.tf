variable "user_data" {
  description = "The user data to provide when launching the instance"
  type     = "list"
  default = ["hostname1.sh","hostname2.sh"] 
}

