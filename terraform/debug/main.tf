variable "origin_config" {
  type = map(object({
    domain_name     = string
    origin_id       = string
    cache_behaviors = map(object({
      path_pattern = string
      compress     = bool
    }))
  }))
}
locals {
  bbb = merge([
    for domain_name, origin_config in var.origin_config : {
      for path_pattern, cache_behavior in origin_config.cache_behaviors :
      "${path_pattern}-${origin_config.origin_id}"=>merge(
        {
          target_origin_id = origin_config.origin_id
        },
        cache_behavior
      )
    }
  ]...)
}