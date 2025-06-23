terraform {
  backend "gcs" {
    bucket = "apps-project-3108449-terra-stg"
    prefix = ""
  }
}