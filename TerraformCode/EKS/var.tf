variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string


}
variable "public_subnet" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)

}
variable "private_subnet" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)

}