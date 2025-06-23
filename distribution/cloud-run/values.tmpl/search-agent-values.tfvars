projectInfo = {    
    project = "<project_id>"
    region = "asia-southeast1"
    serviceAccount = "<service-account-name>@<project_id>.iam.gserviceaccount.com"
}

cloudrunInfo = {
    name = "search-agentlib"
    spec = {
        image = "<repo-name>/search-agentlib:v1.0"
        ingress = "all"
        minCount = "1"
        maxCount = "10"
        traffic = 100
        requests = {
            cpu = "500m"
            memory = "512Mi"
        }
        limits = {
            cpu = "1000m"
            memory = "1Gi"
        }
    }
    ports = {
        name = "http1"
        protocol = "TCP"
        container_port = 80
    }
    envVars = [
    {
        name = "service"
        value = "search-agentlib:v1.0"
    },
    {
        name = "DISCOVERY_ENGINE_HOST"
        value = "discoveryengine.googleapis.com/v1alpha"
    },
    {
        name = "DISCOVERY_ENGINE_SEARCH_PROMPT"
        value = "You are a helpful assistant that answers the given question accurately based on the context provided to you. Make sure you answer the question in as much detail as possible, providing a comprehensive explanation. Do not hallucinate or answer the question by yourself. Provide the final answer in numbered steps. Also explain each steps in detail. Give the final answer in the following format, give the answer directly, dont add any prefix or suffix, Dont give the answer in json or array, just the steps trailed by comma or new line. Dont attach any reference or sources in the answer. If there is some version mention in the question, then get the answer from the contnet of that particular version only, dont take answer from any other version content. If the context contains any contract link relevant to the answer, then provide that link in the answer too. If an example or sample payload can be used to better explain the answer, provide that in the final answer as well. Give the final answer in the following format, give the answer directly, dont add any prefix or suffix. Dont attach any reference or sources in the answer.The user is an expert who has an in-depth understanding of the subject matter. The assistant should answer in a technical manner that uses specialized knowledge and terminology when it helps answer the query."
    },
    {
        name = "PROJECT_ID"
        value = "<project-id>"
    }]
    members = ["allUsers"]
}