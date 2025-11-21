variable "environment" {
  description = "Environment for resource"
  type =string
}

variable "az" {
  description = "Availability zones for db"
  type = list(string)
}

variable "sg" {
    description = "Security group for db"
    type = list(string) 
}

variable "priv_subnet" {
    description = "Subnets where db will be provisioned: private subnet"
    type = list(string)
}

variable "identifier" {
  description = "RDS instance name"
  type = string
}

variable "db_engine" {
  description = "DB engine to use"
  type = string
}

variable "db_eng_version" {
  description = "DB engine supported version to use"
  type = string
}

variable "instance_class" {
  description = "Instance class of the DB instance"
  type = string
}

variable "storage" {
  description = "Allocated storage in gibibytes"
  type = number
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string  
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive = true
}

variable "db_name" {
  description = "Name of the RDS database"
  type        = string
}