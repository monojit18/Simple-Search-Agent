# Simple Search Agent - A naive Search engine for the enterprise

## High Level Design overview

![simple-search-arch](/Users/monojitd/Library/CloudStorage/GoogleDrive-datta.monojit@gmail.com/My Drive/Dumps/Sequelstring/Simple-Search-Agent/Images/simple-search-arch.png)



## Prelude

Deployment uses the following tools:

- **Terraform for GCP** - Infrastructure deployment
- **Cloud Build** - YAML scripts which acts as a wrapper around Terraform Deployment scripts

### Pre-requisites

- ### [Install the gcloud CLI](https://cloud.google.com/sdk/docs/install)

- #### Alternate

  - #### [Run gcloud commands with Cloud Shell](https://cloud.google.com/shell/docs/run-gcloud-commands)

## Step-by-Step guide

Here is a step by step guide on how to deploy this entire infrastructure end to end

### Setup CLI environment variables

```bash
BASEFOLDERPATH=<Root folder path>
DISTRIBUTION_PATH=$BASEFOLDERPATH/distribution
OWNER=<Project Owner ID>
PROJECT_ID=<Project ID>

(Note: This ideally should be same as PROJECT_ID; or any preferred name to identify the proejct)
PROJECT_NAME=<Project NAME>

(Note: Changing the below naming format for GSA_DISPLAY_NAME and GSA will need some change in the some of the deployment file(s) as explained later)
GSA_DISPLAY_NAME=$PROJECT_NAME-sa
GSA=$GSA_DISPLAY_NAME@$PROJECT_ID.iam.gserviceaccount.com
REGION=<GCP Region of the PROJECT>
ZONE=<GCP Zone of the PROJECT>
AI_LOCATION=<GCP Region for VertexAI APIs>
REPO_NAME=<Artifact Registry Repositry>
PACKAGE_NAME="search-agentlib"
PACKAGE_VERSION="v1.0"
```

> [!Note]
>
> **PROJECT_NAME** - This ideally should be same as *PROJECT_ID*; or any preferred name to identify the project.
>
> **GSA_DISPLAY_NAME** - This is the dIsplay name of a *google service account* to be used across this deployment. The recommended format is **$PROJECT_NAME-sa**
>
> **GSA=$GSA_DISPLAY_NAME@$PROJECT_ID.iam.gserviceaccount.com**
>
> Ideally these formats should not be changed as it might impact multiple deployment steps and hence might need modifications in multiple deployment file(s).



#### Authenticate user to gcloud

```bash
gcloud auth login
gcloud auth list
gcloud config set account $OWNER
```

#### Setup current project

```bash
gcloud config set project $PROJECT_ID

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable translate.googleapis.com
gcloud services enable texttospeech.googleapis.com
gcloud services enable vision.googleapis.com
gcloud services enable apigee.googleapis.com
gcloud services enable servicenetworking.googleapis.com
gcloud services enable cloudkms.googleapis.com
gcloud services enable mesh.googleapis.com
gcloud services enable certificatemanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
```

#### Setup Service Account

Current authenticated user will handover control to a **Service Account** which would be used for all subsequent resource deployment and management

```bash
gcloud iam service-accounts create $GSA_DISPLAY_NAME --display-name=$GSA_DISPLAY_NAME
gcloud iam service-accounts list

# Make SA as the owner
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/owner

# ServiceAccountUser role for the SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountUser

# ServiceAccountTokenCreator role for the SA
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$GSA --role=roles/iam.serviceAccountTokenCreator
```

#### Create Storage Buckets

- Bucket to store **Terraform** state (*if terraform deployment is chosen, as explained later*)

  ```bash
  #This is just an example; please feel free to chose any name here of your choice
  gcloud storage buckets create gs://$PROJECT_ID-terra-stg-<some-random-no> --location=us-central1
  ```

- Bucket to store various VertexAI and Generative AI resources


```bash
#This is just an example; please feel free to chose any name here of your choice
gcloud storage buckets create gs://$PROJECT_ID-docs-stg-<some-random-no> --location=us-central1
```

> [!Note]
>
> Important point to note about sharing secured information through deployment files.
>
> This document follows a strict, secured mechanism to share deployment files as every deployment file might have system specific information on where it is getting deployed.
>
> All template deployment files for Helm charts will be shared through a folder called **values.tpl**; which can be found under:
>
> - **/distribution/cloud-run**
>
> **Action**
>
> - Copy **values.tpl** to a folder named as **values**
> - Modify all template files inside newly created **values** folder with the values respective to the target system
> - All subsequent deployment steps will use the **values** folder
>



### Artifact Registry

```bash
#Create Repository
gcloud artifacts repositories create $AR_REPO --repository-format=docker --location=$REGION

#List Repository
gcloud artifacts repositories list --location=$REGION

#Describe Repository
gcloud artifacts repositories describe $AR_REPO --location=$REGION

#gcloud artifacts repositories delete $AR_REPO --location=$REGION
```



### Deploy to Cloud Run

```bash
cd $BASEFOLDERPATH/microservices/agents

#Build container image from source
gcloud builds submit --config="$BASEFOLDERPATH/distribution/builds/app-deploy/app-deploy.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,_PROJECT_NAME_=$PROJECT_NAME,_REGION_=$REGION,\
_REPO_NAME_=$REPO_NAME,_PACKAGE_NAME_=$PACKAGE_NAME,_PACKAGE_VERSION_=$PACKAGE_VERSION,\
_LOG_BUCKET_=$PROJECT_ID-terra-stg

#Distribute package through Cloud Run
cd $BASEFOLDERPATH/distribution
WORKING_DIR="cloud-run"
RESOURCE_NAME="search-agentlib"

gcloud builds submit --config="./builds/cloud-run/run-deploy.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,_PROJECT_NAME_=$PROJECT_NAME,\
_WORKING_DIR_="$WORKING_DIR",_TF_VARS_PATH_="./values/search-agent-values.tfvars",\
_LOG_BUCKET_=$PROJECT_ID-terra-stg,_RESOURCE_NAME_=$RESOURCE_NAME

#gcloud builds submit --config="./builds/cloud-run/run-destroy.yaml" \
--project=$PROJECT_ID --substitutions=_PROJECT_ID_=$PROJECT_ID,_PROJECT_NAME_=$PROJECT_NAME,\
_WORKING_DIR_="$WORKING_DIR",_TF_VARS_PATH_="./values/search-agent-values.tfvars",\
_LOG_BUCKET_=$PROJECT_ID-terra-stg,_RESOURCE_NAME_=$RESOURCE_NAME
```

# References

- [Vertex AI](https://cloud.google.com/vertex-ai/docs)
- [Generative AI on Vertex AI](https://cloud.google.com/vertex-ai/generative-ai/docs/learn/overview)
- [VertexAI Search](https://cloud.google.com/generative-ai-app-builder/docs/introduction)

