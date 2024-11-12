terraform{
    backend "s3" {
        bucket = "opentofu"
        key = "terraform.tfstate"

        endpoints = {
            s3 = "<minio endpoint>"
        }
        access_key= "<access-key>"
        secret_key= ">secret-key"

        region = "main"
        skip_credentials_validation = true
        skip_requesting_account_id = true
        skip_metadata_api_check = true
        skip_region_validation = true
        use_path_style = true
    }
}