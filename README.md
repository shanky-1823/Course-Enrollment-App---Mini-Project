# Course Enrollment App - Mini Project

End-to-end steps to deploy to a Salesforce org using the Salesforce CLI (sf), assign permission sets, and load sample data via the CourseAppDataLoader Apex class.

Prerequisites
- Salesforce CLI (sf)
- Git

1) Org setup (clone and authenticate)
- Clone and change directory:
  - git clone <Github Repo URL>
  - cd "<your-repo>"

- Authenticate to an org (choose one):
  - Directly to a developer org:
    - sf org login web --alias TargetOrg --set-default

2) Deploy metadata to the org
- If using the default target org (scratch or a previously set default):
  - sf project deploy start

3) Assign permission set(s)
If your project contains a permission set (e.g., Course_App_Admin or Course_App_User), run:
- sf org assign permset --name <Permission_Set_API_Name> --target-org <alias-or-username>

Examples:
- sf org assign permset --name Course_Enrollment_App_User --target-org CourseApp

4) Data load via CourseAppDataLoader Apex class
There are two reliable ways to run the data loader logic:

A) Run an Apex script that invokes your loader class (recommended)
- Create scripts/apex/hello.apex (example) that calls your entry method:
  - CourseAppDataLoader.loadAll(); // Example – adjust to your class’s public entry method

B) Execute Apex inline
- If your class exposes a static entry method:
  - sf apex run --target-org CourseApp --apex "CourseAppDataLoader.loadAll();"

C) Static resources note
Read the JSONs in the data folder that are used as static resources. The CourseAppDataLoader Apex class reads the data from Static Resources (course_attendees.json, course_courses.json, course_enrolments.json, course_trainers.json), make sure those are deployed (they are under force-app/main/default/staticresources). After deployment, run the entry method as shown above.

5) Optional alternative: Data import plan
If you prefer a non-Apex import for sample data, provide a data import plan (CSV/JSON) and use:
- sf data import tree --plan data/plan.json --target-org CourseApp

6) Post-deployment verification
- Open the org:
  - sf org open --target-org CourseApp

- Verify the app and tabs:
  - Open the Course Management App
  - Review Course__c, Course_Enrolment__c, and Contact list views and layouts

- Optional quick SOQL checks:
  - sf data query --query "SELECT Id, Name, Course_Code__c FROM Course__c LIMIT 10" --target-org CourseApp
  - sf data query --query "SELECT Id, Name, Status__c FROM Course_Enrolment__c LIMIT 10" --target-org CourseApp



- Quick Start:
  - git clone https://github.com/<your-org-or-user>/<your-repo>.git
  - cd "<your-repo>"
  - sf org create scratch --definition-file config/project-scratch-def.json --alias CourseApp --set-default
  - sf project deploy start --target-org CourseApp
  - sf org assign permset --name Course_Enrollment_App_User --target-org CourseApp
  - sf apex run --file scripts/apex/loadCourseData.apex --target-org CourseApp
  - sf org open --target-org CourseApp