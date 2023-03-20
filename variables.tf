variable "role_name" {
  description = "Role name"
  type = string
}

variable "role_description" {
  description = "Role description"
  type = string
  default = null
}

variable "role_policy_arns" {
  description = "Role managed policy ARNs"
  type = list(string)
  default = null
}

variable "role_max_session_duration" {
  description = "Role max session duration"
  type = number
  default = null
}

variable "role_path" {
  description = "Role path"
  type = string
  default = null
}

variable "role_permissions_boundary" {
  description = "Role permissions boundary"
  type = string
  default = null
}

variable "custom_policies" {
  description = "List of the custom policies"
  type = list(object({
    name        = string
    policy      = any
    path        = optional(string)
    description = optional(string)
    tags        = optional(any)
  }))
  default = []
}

variable "oidc_url" {
  description = "The URL of the identity provider. Corresponds to the iss claim"
  type = string
}

variable "oidc_thumbprint_list" {
  description = "A list of server certificate thumbprints for the OpenID Connect (OIDC) identity provider's server certificate(s)"
  type = list(string)
}

variable "oidc_main_policy" {
  description = "Conditions and additional principals to main policy to web identity provider"
  type = object({
    conditions = list(object({
      test     = string
      variable = string
      values   = list(string)
    }))
    principals = optional(list(object({
      type        = string
      identifiers = optional(list(string))
    })))
  })
}

variable "oidc_client_id_list" {
  description = "A list of client IDs (also known as audiences). When a mobile or web app registers with an OpenID Connect provider, they establish a value that identifies the application. (This is the value that's sent as the client_id parameter on OAuth requests"
  type = list(string)
  default = ["sts.amazonaws.com"]
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "use_tags_default" {
  description = "If true will be use the tags default"
  type        = bool
  default     = true
}

variable "tags_provider" {
  description = "Tags to identity provider"
  type        = map(any)
  default     = {}
}

variable "tags_role" {
  description = "Tags to role"
  type        = map(any)
  default     = {}
}
