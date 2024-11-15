# OCR
OCR project in GCP 

Vertex AI Workbench
Infrastructure config note:
1. root access allows for cron job
2. not external IP for workbench, but can set up cloud NAT with cloud VPC to have external IP
   which allows for connection to internet
3. R and python kernal 



infra concern
- We’d probably want the NB instance in a custom vpc network instead of the default one so that it’s closer to prod. Plus we can tune firewalls later with a clean slate if necessary.
- The notebook instance could use it’s own custom service account because the default compute engine one has editor role in the project.


Process:
1. create project
2. create secret manager and secret storing config needed for the environment
3. run terraform script