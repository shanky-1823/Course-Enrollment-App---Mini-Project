public with sharing class CourseAppDataLoader {

    public static void loadData() {

        Id trainerRtId = getContactRecordTypeId('Trainer');
        Id attendeeRtId = getContactRecordTypeId('Attendee');

        List<Contact> trainers  = loadTrainers(trainerRtId);
        List<Contact> attendees = loadAttendees(attendeeRtId);
        List<Course__c> courses = loadCourses(trainers);
        loadEnrolments(attendees, courses);

        System.debug('Course Management App data loaded successfully');
    }


    private static Id getContactRecordTypeId(String name) {
        return [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Contact'
              AND Name = :name
            LIMIT 1
        ].Id;
    }


    private static List<Contact> loadTrainers(Id recordTypeId) {

        List<Object> data = readJsonArray('course_trainers');
        List<Contact> records = new List<Contact>();

        for (Object o : data) {
            Map<String, Object> m = (Map<String, Object>) o;

            records.add(new Contact(
                FirstName        = (String) m.get('firstName'),
                LastName         = (String) m.get('lastName'),
                Email            = (String) m.get('email'),
                RecordTypeId     = recordTypeId,
                Contact_Role__c  = 'Trainer',
                Trainer_Level__c = (String) m.get('level'),
                Status__c        = 'Active'
            ));
        }

        Database.insert(records, false);
        return records;
    }


    private static List<Contact> loadAttendees(Id recordTypeId) {

        List<Object> data = readJsonArray('course_attendees');
        List<Contact> records = new List<Contact>();

        for (Object o : data) {
            Map<String, Object> m = (Map<String, Object>) o;

            records.add(new Contact(
                FirstName               = (String) m.get('firstName'),
                LastName                = (String) m.get('lastName'),
                Email                   = (String) m.get('email'),
                RecordTypeId            = recordTypeId,
                Contact_Role__c         = 'Attendee',
                Student_Status__c       = 'Active',
                Learning_Preference__c  = (String) m.get('learningPreference'),
                Status__c               = 'Active'
            ));
        }

        Database.insert(records, false);
        return records;
    }


    private static List<Course__c> loadCourses(List<Contact> trainers) {

        List<Object> data = readJsonArray('course_courses');
        List<Course__c> records = new List<Course__c>();

        for (Object o : data) {
            Map<String, Object> m = (Map<String, Object>) o;
            Integer trainerIndex = (Integer) m.get('trainerIndex');

            records.add(new Course__c(
                Name           = (String) m.get('name'),
                Course_Code__c = (String) m.get('code'),
                Capacity__c    = (Integer) m.get('capacity'),
                Status__c      = 'Planned',
                Course_Type__c = 'Technical',
                Trainer__c     = trainers[trainerIndex].Id,
                Start_Date__c  = Date.today().addDays(7),
                End_Date__c    = Date.today().addDays(30)
            ));
        }

        Database.insert(records, false);
        return records;
    }


    private static void loadEnrolments(
        List<Contact> attendees,
        List<Course__c> courses
    ) {
        List<Object> data = readJsonArray('course_enrolments');
        List<Course_Enrolment__c> records = new List<Course_Enrolment__c>();

        for (Object o : data) {
            Map<String, Object> m = (Map<String, Object>) o;

            records.add(new Course_Enrolment__c(
                Attendee__c       = attendees[(Integer) m.get('attendeeIndex')].Id,
                Course__c        = courses[(Integer) m.get('courseIndex')].Id,
                Status__c        = 'Enrolled',
                Enrolment_Date__c= Date.today(),
                Is_Active__c     = true
            ));
        }

        Database.insert(records, false);
    }


    private static List<Object> readJsonArray(String staticResourceName) {

        StaticResource sr = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :staticResourceName
            LIMIT 1
        ];

        return (List<Object>) JSON.deserializeUntyped(sr.Body.toString());
    }
}