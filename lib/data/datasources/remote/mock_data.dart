// Realistic mock JSON data matching the UI designs.
//
// Used by MockInterceptor to simulate API responses during development.
// Each list mirrors the fields expected by the corresponding data model.

List<Map<String, dynamic>> mockAnnouncements = [
  {
    'id': '1',
    'title': 'Campus Library Extended Hours',
    'body':
        'Starting next week, the main campus library will extend its operating '
        'hours until midnight on weekdays to support students during the exam '
        'period. The quiet study zones on the 3rd floor will remain accessible '
        '24/7 with valid student ID. Refreshments will be available at the '
        'ground floor café until 10 PM.',
    'category': 'Academic',
    'date': '2026-04-07T09:00:00',
    'summary':
        'Library hours extended to midnight on weekdays during exam '
        'period. 3rd floor open 24/7.',
    'source': 'Academic Affairs',
    'readTime': 3,
    'isBookmarked': false,
  },
  {
    'id': '2',
    'title': 'Wi-Fi Network Maintenance',
    'body':
        'The IT department will be performing scheduled maintenance on the '
        'campus Wi-Fi infrastructure this Saturday from 2 AM to 6 AM. During '
        'this window, connectivity may be intermittent across all buildings. '
        'We recommend downloading any materials you need for offline access '
        'before Friday evening.',
    'category': 'IT Services',
    'date': '2026-04-05T14:30:00',
    'summary':
        'Scheduled Wi-Fi maintenance Saturday 2-6 AM. Download '
        'materials beforehand.',
    'source': 'IT Department',
    'readTime': 2,
    'isBookmarked': true,
  },
  {
    'id': '3',
    'title': 'Spring Semester Registration Open',
    'body':
        'Online registration for the Spring 2026 semester is now open. '
        'Priority registration for seniors begins April 10, followed by '
        'juniors on April 12, sophomores on April 14, and freshmen on '
        'April 16. Please review your degree audit before registering to '
        'ensure you are on track for graduation.',
    'category': 'Registration',
    'date': '2026-04-04T08:00:00',
    'summary':
        'Spring 2026 registration is open. Senior priority starts '
        'April 10.',
    'source': 'Registrar Office',
    'readTime': 4,
    'isBookmarked': false,
  },
  {
    'id': '4',
    'title': 'New Parking Policy Update',
    'body':
        'Effective May 1, all student vehicles must display the new digital '
        'parking permit. Physical stickers will no longer be accepted. '
        'Register your vehicle through the campus portal under '
        'Services > Parking. First-time registration is free; replacements '
        'cost \$15.',
    'category': 'Administration',
    'date': '2026-04-03T11:00:00',
    'summary':
        'Digital parking permits required from May 1. Register free '
        'via campus portal.',
    'source': 'Campus Security',
    'readTime': 3,
    'isBookmarked': false,
  },
  {
    'id': '5',
    'title': 'Mental Health Awareness Week',
    'body':
        'Join us for Mental Health Awareness Week from April 14-18. '
        'Activities include free counseling sessions, yoga workshops, a '
        'panel discussion with mental health professionals, and a campus '
        'walk for wellness. All events are free and open to students, '
        'faculty, and staff.',
    'category': 'Wellness',
    'date': '2026-04-02T10:00:00',
    'summary':
        'Free counseling, yoga, and wellness events April 14-18. '
        'Open to all.',
    'source': 'Student Wellness Center',
    'readTime': 5,
    'isBookmarked': true,
  },
];

List<Map<String, dynamic>> mockEvents = [
  {
    'id': '1',
    'title': 'AI & Machine Learning Workshop',
    'description':
        'Hands-on workshop covering the fundamentals of machine learning '
        'with Python. Bring your laptop with Python 3.10+ installed. '
        'Beginners welcome — no prior ML experience required.',"C:\Users\MAXFRAME\OneDrive\Pictures\Screenshots\Screenshot 2026-04-23 094051.png"
    'location': 'Engineering Building, Room 301',
    'dateTime': '2026-04-10T10:00:00',
    'imageUrl': null,
    'endTime': '2026-04-10T12:30:00',
    'category': 'Workshop',
    'attendeeCount': 47,
    'isReminded': false,
  },
  {
    'id': '2',
    'title': 'Inter-University Basketball Tournament',
    'description':
        'Cheer on our team as they compete in the regional quarter-finals '
        'against State University. Food trucks and live music before the '
        'game. Free entry with student ID.',
    'location': 'Sports Complex, Main Court',
    'dateTime': '2026-04-12T15:00:00',
    'imageUrl': null,
    'endTime': '2026-04-12T18:00:00',
    'category': 'Sports',
    'attendeeCount': 156,
    'isReminded': true,
  },
  {
    'id': '3',
    'title': 'Career Fair 2026',
    'description':
        'Over 50 companies will be on campus recruiting for internships '
        'and full-time positions. Bring copies of your resume. '
        'Professional attire recommended. Pre-register on the career '
        'services portal for priority access.',
    'location': 'Student Union, Grand Hall',
    'dateTime': '2026-04-15T09:00:00',
    'imageUrl': null,
    'endTime': '2026-04-15T16:00:00',
    'category': 'Career',
    'attendeeCount': 312,
    'isReminded': false,
  },
  {
    'id': '4',
    'title': 'Open Mic Night',
    'description':
        'Show off your talent at the monthly open mic night! Sing, play '
        'an instrument, do stand-up comedy, or share spoken word poetry. '
        'Sign up at the student activities desk by April 16.',
    'location': 'Campus Café, Ground Floor',
    'dateTime': '2026-04-18T19:00:00',
    'imageUrl': null,
    'endTime': '2026-04-18T22:00:00',
    'category': 'Social',
    'attendeeCount': 23,
    'isReminded': false,
  },
  {
    'id': '5',
    'title': 'Research Symposium',
    'description':
        'Annual undergraduate research symposium featuring poster '
        'presentations and oral talks from students across all '
        'departments. Attend to discover cutting-edge student research '
        'and network with faculty mentors.',
    'location': 'Science Building, Auditorium',
    'dateTime': '2026-04-20T08:30:00',
    'imageUrl': null,
    'endTime': '2026-04-20T17:00:00',
    'category': 'Academic',
    'attendeeCount': 89,
    'isReminded': true,
  },
];

List<Map<String, dynamic>> mockTimetable = [
  {
    'id': '1',
    'courseName': 'Mobile Application Development',
    'instructor': 'Dr. Sarah Chen',
    'room': 'CS-204',
    'dayOfWeek': 1,
    'startTime': '08:30',
    'endTime': '10:00',
    'status': 'Completed',
  },
  {
    'id': '2',
    'courseName': 'Data Structures & Algorithms',
    'instructor': 'Prof. James Miller',
    'room': 'CS-101',
    'dayOfWeek': 1,
    'startTime': '10:30',
    'endTime': '12:00',
    'status': 'In Progress',
  },
  {
    'id': '3',
    'courseName': 'Database Systems',
    'instructor': 'Dr. Amina Patel',
    'room': 'CS-305',
    'dayOfWeek': 2,
    'startTime': '09:00',
    'endTime': '10:30',
    'status': 'Upcoming',
  },
  {
    'id': '4',
    'courseName': 'Operating Systems',
    'instructor': 'Prof. Robert Kim',
    'room': 'ENG-112',
    'dayOfWeek': 2,
    'startTime': '13:00',
    'endTime': '14:30',
    'status': 'Upcoming',
  },
  {
    'id': '5',
    'courseName': 'Software Engineering',
    'instructor': 'Dr. Lisa Wang',
    'room': 'CS-202',
    'dayOfWeek': 3,
    'startTime': '08:30',
    'endTime': '10:00',
    'status': 'Upcoming',
  },
  {
    'id': '6',
    'courseName': 'Mobile Application Development',
    'instructor': 'Dr. Sarah Chen',
    'room': 'CS-204',
    'dayOfWeek': 3,
    'startTime': '10:30',
    'endTime': '12:00',
    'status': 'Upcoming',
  },
  {
    'id': '7',
    'courseName': 'Computer Networks',
    'instructor': 'Prof. David Brown',
    'room': 'ENG-201',
    'dayOfWeek': 4,
    'startTime': '14:00',
    'endTime': '15:30',
    'status': 'Upcoming',
  },
  {
    'id': '8',
    'courseName': 'Data Structures & Algorithms',
    'instructor': 'Prof. James Miller',
    'room': 'CS-101',
    'dayOfWeek': 5,
    'startTime': '10:30',
    'endTime': '12:00',
    'status': 'Upcoming',
  },
];
