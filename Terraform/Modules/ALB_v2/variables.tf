########################
#####  Variables  ######
#######################

variable "Environment" {
  type = string
}

variable "Subnets" {
  type = list(string)
}

variable "SecurityGroup" {
  type = string
}

variable "VPC" {
  type = string
}

variable "Cert_ARN" {
  type = string
}

variable "Internal" {
  default = false
}

variable "AddRule" {
  type = string
}

variable "Random_Id" {
  type = string
}

variable "Target_Group" {
  type = string
}

variable "Enable_Logs" {
  type    = bool
  default = false
}

variable "idleTimeout" {
  type    = number
  default = 60
}

variable "ALB_Rules_Redirects" {
  type = list(
    object({
      Origin_Host       = string
      Path_Origin       = string
      Destination_Host  = string
      Path_Destination  = string
      Query_destination = string
    })
  )
  default = [
    {
      Origin_Host       = "aramark.client.com"
      Path_Origin       = "/2019"
      Destination_Host  = "aramark.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=Social&utm_medium=learner&utm_campaign=launch"
    },
    {
      Origin_Host       = "aramark.client.com"
      Path_Origin       = "/launch"
      Destination_Host  = "aramark.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=postcard&utm_campaign=launch"
    },
    {
      Origin_Host       = "aramark.client.com"
      Path_Origin       = "/frontline"
      Destination_Host  = "aramark.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyerposter&utm_campaign=launch"
    },
    {
      Origin_Host       = "aramark.client.com"
      Path_Origin       = "/2020"
      Destination_Host  = "aramark.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=2020"
    },
    {
      Origin_Host       = "gilarivergaming.client.com"
      Path_Origin       = "/spring"
      Destination_Host  = "gilarivergaming.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=signage&utm_medium=print&utm_campaign=spring"
    },
    {
      Origin_Host       = "gilarivercommunity.client.com"
      Path_Origin       = "/spring"
      Destination_Host  = "gilarivercommunity.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=signage&utm_medium=print&utm_campaign=spring"
    },
    {
      Origin_Host       = "prime.client.com"
      Path_Origin       = "/launch"
      Destination_Host  = "prime.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=internal&utm_medium=video&utm_campaign=launch"
    },
    {
      Origin_Host       = "prime.client.com"
      Path_Origin       = "/get-started"
      Destination_Host  = "prime.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "prime.client.com"
      Path_Origin       = "/scholars"
      Destination_Host  = "prime.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=internal&utm_medium=portal&utm_campaign=launch"
    },
    {
      Origin_Host       = "carvana.client.com"
      Path_Origin       = "/launch"
      Destination_Host  = "carvana.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "carvana.client.com"
      Path_Origin       = "/get-started"
      Destination_Host  = "carvana.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=internal&utm_medium=video&utm_campaign=launch"
    },
    {
      Origin_Host       = "carvana.client.com"
      Path_Origin       = "/keys"
      Destination_Host  = "carvana.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=internal&utm_medium=social&utm_campaign=launch"
    },
    {
      Origin_Host       = "adidas.client.com"
      Path_Origin       = "/asu"
      Destination_Host  = "adidas.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=expansion"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/launch"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/Launch"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/LAUNCH"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/get-started"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=poster&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/Get-started"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=poster&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/Get-Started"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=poster&utm_campaign=launch"
    },
    {
      Origin_Host       = "labcorp.client.com"
      Path_Origin       = "/2021"
      Destination_Host  = "labcorp.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=postcard&utm_campaign=launch"
    },
    {
      Origin_Host       = "abcfoundations.client.com"
      Path_Origin       = "/launch"
      Destination_Host  = "abcfoundations.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "abcfoundations.client.com"
      Path_Origin       = "/Launch"
      Destination_Host  = "abcfoundations.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=flyer&utm_campaign=launch"
    },
    {
      Origin_Host       = "abcfoundations.client.com"
      Path_Origin       = "/get-started"
      Destination_Host  = "abcfoundations.client.com"
      Path_Destination  = "/"
      Query_destination = "utm_source=print&utm_medium=poster&utm_campaign=launch"
    }


  ]
}
