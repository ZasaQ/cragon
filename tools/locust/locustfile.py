from locust import HttpUser, TaskSet, task, between

class CloudFunctionTasks(TaskSet):

    @task
    def get_request(self):
        self.client.get("https://us-central1-cragon-application.cloudfunctions.net/getData")

    @task
    def post_request(self):
        self.client.post("https://us-central1-cragon-application.cloudfunctions.net/postData", 
                         json={"message": "Hello, World!"})

class CloudFunctionUser(HttpUser):
    tasks = [CloudFunctionTasks]
    host = "https://us-central1-cragon-application.cloudfunctions.net"