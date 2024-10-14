import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  // Dummy data for events
  final List<Map<String, String>> events = [
    {
      'title': 'Arutti Show Skylien Plaza',
      'description': 'A spectacular show with the best models in the industry.',
      'place': 'Skylien Plaza, Frankfurt',
      'date': '2024-11-05'
    },
    {
      'title': 'LeoGarn Show Zeil',
      'description':
          'Fashion show featuring the latest collections from LeoGarn.',
      'place': 'Zeil, Frankfurt',
      'date': '2024-11-12'
    },
    {
      'title': 'Arutti Dance Show Mainz',
      'description': 'A dance extravaganza with stunning performances.',
      'place': 'Mainz City Hall',
      'date': '2024-11-20'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Fahkwang',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: EventCard(
                    title: events[index]['title']!,
                    description: events[index]['description']!,
                    place: events[index]['place']!,
                    date: events[index]['date']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String place;
  final String date;

  const EventCard({
    required this.title,
    required this.description,
    required this.place,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Fahkwang',
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Fahkwang',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Location: $place',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Fahkwang',
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Date: $date',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Fahkwang',
            ),
          ),
        ],
      ),
    );
  }
}
